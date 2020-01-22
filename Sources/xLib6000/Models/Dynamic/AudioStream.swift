//
//  AudioStream.swift
//  xLib6000
//
//  Created by Douglas Adams on 2/24/17.
//  Copyright © 2017 Douglas Adams & Mario Illgen. All rights reserved.
//

import Foundation

public typealias AudioStreamId = StreamId

/// AudioStream Class implementation
///
///      creates an AudioStream instance to be used by a Client to support the
///      processing of a stream of Audio from the Radio to the client. AudioStream
///      objects are added / removed by the incoming TCP messages. AudioStream
///      objects periodically receive Audio in a UDP stream.
///
public final class AudioStream : NSObject, DynamicModelWithStream {
  
  // ------------------------------------------------------------------------------
  // MARK: - Public properties
  
  public      let id         : AudioStreamId
  
  public var delegate : StreamHandler? {
    get { Api.objectQ.sync { _delegate } }
    set { Api.objectQ.sync(flags: .barrier) {_delegate = newValue }}}

  @objc dynamic public var daxChannel: Int {
    get { _daxChannel }
    set { if _daxChannel != newValue { _daxChannel = newValue ; _slice = _radio.findSlice(using: _daxChannel) }}}
  
  @objc dynamic public var daxClients: Int {
    get { _daxClients  }
    set { if _daxClients != newValue { _daxClients = newValue }}}

  @objc dynamic public var inUse: Bool { _inUse }

  @objc dynamic public var ip: String {
    get { _ip }
    set { if _ip != newValue { _ip = newValue }}}

  @objc dynamic public var port: Int {
    get { _port  }
    set { if _port != newValue { _port = newValue }}}
  
  @objc dynamic public var rxGain: Int {
    get { _rxGain  }
    set { if _rxGain != newValue { _rxGain = newValue ; if _slice != nil && !Api.sharedInstance.testerModeEnabled { audioStreamCmd( "gain", newValue) }}}}
    
  @objc dynamic public var slice: xLib6000.Slice? {
    get { _slice }
    set { if _slice != newValue { _slice = newValue }}}

  public private(set) var rxLostPacketCount         = 0
    
  // ------------------------------------------------------------------------------
  // MARK: - Internal properties
    
  var _daxChannel : Int {
    get { Api.objectQ.sync { __daxChannel } }
    set { Api.objectQ.sync(flags: .barrier) {__daxChannel = newValue }}}
  var _daxClients : Int {
    get { Api.objectQ.sync { __daxClients } }
    set { Api.objectQ.sync(flags: .barrier) {__daxClients = newValue }}}
  var _inUse : Bool {
    get { Api.objectQ.sync { __inUse } }
    set { Api.objectQ.sync(flags: .barrier) {__inUse = newValue }}}
  var _ip : String {
    get { Api.objectQ.sync { __ip } }
    set { Api.objectQ.sync(flags: .barrier) {__ip = newValue }}}
  var _port : Int {
    get { Api.objectQ.sync { __port } }
    set { Api.objectQ.sync(flags: .barrier) {__port = newValue }}}
  var _rxGain : Int {
    get { Api.objectQ.sync { __rxGain } }
    set { Api.objectQ.sync(flags: .barrier) {__rxGain = newValue }}}
  var _slice : xLib6000.Slice? {
    get { Api.objectQ.sync { __slice } }
    set { Api.objectQ.sync(flags: .barrier) {__slice = newValue }}}

  internal enum Token: String {
    case daxChannel                         = "dax"
    case daxClients                         = "dax_clients"
    case inUse                              = "in_use"
    case ip
    case port
    case slice
  }
  
  // ------------------------------------------------------------------------------
  // MARK: - Private properties
  
  private      let _radio                   : Radio
  private      var _initialized             = false
  private      var _rxSeq                   : Int?
  private      let _log                     = Log.sharedInstance.msg

  // ------------------------------------------------------------------------------
  // MARK: - Class methods

  /// Parse an AudioStream status message
  ///   Format:  <streamId, > <"dax", channel> <"in_use", 1|0> <"slice", number> <"ip", ip> <"port", port>
  ///
  ///   StatusParser Protocol method, executes on the parseQ
  ///
  /// - Parameters:
  ///   - keyValues:      a KeyValuesArray
  ///   - radio:          the current Radio class
  ///   - queue:          a parse Queue for the object
  ///   - inUse:          false = "to be deleted"
  ///
  class func parseStatus(_ radio: Radio, _ keyValues: KeyValuesArray, _ inUse: Bool = true) {
    
    //get the Id
    if let audioStreamId =  keyValues[0].key.streamId {
      
      // is the AudioStream in use?
      if inUse {
        
        // YES, does the object exist?
        if radio.audioStreams[audioStreamId] == nil {
          
          // NO, is this stream for this client?
          if !isForThisClient(keyValues) { return }
          
          // create a new object & add it to the collection
          radio.audioStreams[audioStreamId] = AudioStream(radio: radio, id: audioStreamId)
        }
        // pass the remaining key values for parsing (dropping the Id)
        radio.audioStreams[audioStreamId]!.parseProperties(radio, Array(keyValues.dropFirst(1)) )
        
      } else {
        
        // does the object exist?
        if let stream = radio.audioStreams[audioStreamId] {
          
          // notify all observers
          NC.post(.audioStreamWillBeRemoved, object: stream as Any?)
          
          // remove the object
          radio.audioStreams[audioStreamId] = nil
        }
      }
    }
  }
  
  // ------------------------------------------------------------------------------
  // MARK: - Initialization
  
  /// Initialize an AudioStream
  ///
  /// - Parameters:
  ///   - radio:        the Radio instance
  ///   - id:           an AudioStream Id
  ///
  init(radio: Radio, id: AudioStreamId) {
    
    _radio = radio
    self.id = id
    super.init()
  }

  // ------------------------------------------------------------------------------
  // MARK: - Instance methods
  
  /// Parse Audio Stream key/value pairs
  ///
  ///   PropertiesParser Protocol method, executes on the parseQ
  ///
  /// - Parameter properties:       a KeyValuesArray
  ///
  func parseProperties(_ radio: Radio, _ properties: KeyValuesArray) {
    
    // process each key/value pair, <key=value>
    for property in properties {
      
      // check for unknown Keys
      guard let token = Token(rawValue: property.key) else {
        // log it and ignore the Key
        _log("Unknown AudioStream token: \(property.key) = \(property.value)", .warning, #function, #file, #line)
        continue
      }
      // known keys, in alphabetical order
      switch token {
        
      case .daxChannel: update(self, &_daxChannel,  to: property.value.iValue,  signal: \.daxChannel)
      case .daxClients: update(self, &_daxClients,  to: property.value.iValue,  signal: \.daxClients)
      case .inUse:      update(self, &_inUse,       to: property.value.bValue,  signal: \.inUse)
      case .ip:         update(self, &_ip,          to: property.value,         signal: \.ip)
      case .port:       update(self, &_port,        to: property.value.iValue,  signal: \.port)
      case .slice:
        if let sliceId = property.value.objectId {
          update(self, &_slice, to: _radio.slices[sliceId], signal: \.slice)
        }
        let gain = _rxGain
        _rxGain = 0
        rxGain = gain
      }
    }    
    // if this is not yet initialized and inUse becomes true
    if !_initialized && _inUse && _ip != "" {
      
      // YES, the Radio (hardware) has acknowledged this Audio Stream
      _initialized = true
      
      // notify all observers
      NC.post(.audioStreamHasBeenAdded, object: self as Any?)
    }
  }
  /// Remove this Audio Stream
  ///
  /// - Parameters:
  ///   - callback:           ReplyHandler (optional)
  ///
  public func remove(callback: ReplyHandler? = nil) {
    
    // tell the Radio to remove a Stream
    _radio.sendCommand("stream remove " + "\(id.hex)", replyTo: callback)
    
    // notify all observers
    NC.post(.audioStreamWillBeRemoved, object: self as Any?)
  }

  // ------------------------------------------------------------------------------
  // MARK: - Stream methods
  
  /// Process the AudioStream Vita struct
  ///
  ///   VitaProcessor Protocol method, executes on the streamQ
  ///      The payload of the incoming Vita struct is converted to an AudioStreamFrame and
  ///      passed to the Audio Stream Handler, called by Radio
  ///
  /// - Parameters:
  ///   - vita:       a Vita struct
  ///
  func vitaProcessor(_ vita: Vita) {
    
    // if there is a delegate, process the Panadapter stream
    if let delegate = delegate {
      
      let payloadPtr = UnsafeRawPointer(vita.payloadData)
      
      // initialize a data frame
      var dataFrame = AudioStreamFrame(payload: payloadPtr, numberOfBytes: vita.payloadSize)
      
      dataFrame.daxChannel = self.daxChannel
      
      // get a pointer to the data in the payload
      let wordsPtr = payloadPtr.bindMemory(to: UInt32.self, capacity: dataFrame.samples * 2)
      
      // allocate temporary data arrays
      var dataLeft = [UInt32](repeating: 0, count: dataFrame.samples)
      var dataRight = [UInt32](repeating: 0, count: dataFrame.samples)
      
      // swap endianess on the bytes
      // for each sample if we are dealing with DAX audio
      
      // Swap the byte ordering of the samples & place it in the dataFrame left and right samples
      for i in 0..<dataFrame.samples {
        
        dataLeft[i] = CFSwapInt32BigToHost(wordsPtr.advanced(by: 2*i+0).pointee)
        dataRight[i] = CFSwapInt32BigToHost(wordsPtr.advanced(by: 2*i+1).pointee)
      }
      // copy the data as is -- it is already floating point
      memcpy(&(dataFrame.leftAudio), &dataLeft, dataFrame.samples * 4)
      memcpy(&(dataFrame.rightAudio), &dataRight, dataFrame.samples * 4)
      
      // Pass the data frame to this AudioSream's delegate
      delegate.streamHandler(dataFrame)
    }
    
    // calculate the next Sequence Number
    let expectedSequenceNumber = (_rxSeq == nil ? vita.sequence : (_rxSeq! + 1) % 16)
    
    // is the received Sequence Number correct?
    if vita.sequence != expectedSequenceNumber {
      
      // NO, log the issue
      _log("Missing AudioStream packet(s), rcvdSeq: \(vita.sequence),  != expectedSeq: \(expectedSequenceNumber)", .debug, #function, #file, #line)

      _rxSeq = nil
      rxLostPacketCount += 1
    } else {
      
      _rxSeq = expectedSequenceNumber
    }
  }
  // ----------------------------------------------------------------------------
  // MARK: - Private methods

  /// Set an Audio Stream property on the Radio
  ///
  /// - Parameters:
  ///   - token:      the parse token
  ///   - value:      the new value
  ///
  private func audioStreamCmd(_ token: String, _ value: Any) {
    _radio.sendCommand("audio stream " + "\(id.hex) slice \(_slice!.id) " + token + " \(value)")
  }
  
  // ----------------------------------------------------------------------------
  // *** Hidden properties (Do NOT use) ***
  
  private var _delegate     : StreamHandler? = nil

  private var __daxChannel  = 0
  private var __daxClients  = 0
  private var __inUse       = false
  private var __ip          = ""
  private var __port        = 0
  private var __rxGain      = 50
  private var __slice       : xLib6000.Slice? = nil
}

