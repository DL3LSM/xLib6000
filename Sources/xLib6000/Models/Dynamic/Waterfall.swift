//
//  Waterfall.swift
//  xLib6000
//
//  Created by Douglas Adams on 5/31/15.
//  Copyright (c) 2015 Douglas Adams, K3TZR
//

import Foundation

public typealias WaterfallStreamId = StreamId

/// Waterfall Class implementation
///
///      creates a Waterfall instance to be used by a Client to support the
///      processing of a Waterfall. Waterfall objects are added / removed by the
///      incoming TCP messages. Waterfall objects periodically receive Waterfall
///      data in a UDP stream. They are collected in the waterfalls collection
///      on the Radio object.
///
public final class Waterfall : NSObject, DynamicModelWithStream {
  
  // ----------------------------------------------------------------------------
  // MARK: - Public properties
    
  public      let id              : WaterfallStreamId
  public      var isStreaming     = false

  public var delegate : StreamHandler? {
    get { Api.objectQ.sync { _delegate } }
    set { Api.objectQ.sync(flags: .barrier) {_delegate = newValue }}}

  @objc dynamic public var autoBlackEnabled: Bool {
    get { _autoBlackEnabled }
    set { if _autoBlackEnabled != newValue { _autoBlackEnabled = newValue ; waterfallCmd( .autoBlackEnabled, newValue.as1or0) }}}
  
  @objc dynamic public var autoBlackLevel: UInt32 {
    return _autoBlackLevel }
  
  @objc dynamic public var blackLevel: Int {
    get { _blackLevel }
    set { if _blackLevel != newValue { _blackLevel = newValue ; waterfallCmd( .blackLevel, newValue) }}}
  
  @objc dynamic public var clientHandle: Handle { _clientHandle }
  
  @objc dynamic public var colorGain: Int {
    get { _colorGain }
    set { if _colorGain != newValue { _colorGain = newValue ; waterfallCmd( .colorGain, newValue) }}}
  
  @objc dynamic public var gradientIndex: Int {
    get { _gradientIndex }
    set { if _gradientIndex != newValue { _gradientIndex = newValue ; waterfallCmd( .gradientIndex, newValue) }}}
  
  @objc dynamic public var lineDuration: Int {
    get { _lineDuration }
    set { if _lineDuration != newValue { _lineDuration = newValue ; waterfallCmd( .lineDuration, newValue) }}}
  
  @objc dynamic public var panadapterId: PanadapterStreamId { _panadapterId }
  
  public private(set) var droppedPackets  = 0
  public private(set) var packetFrame     = -1

  // ----------------------------------------------------------------------------
  // MARK: - Internal properties
    
  var _autoBlackEnabled: Bool {
    get { Api.objectQ.sync { __autoBlackEnabled } }
    set { Api.objectQ.sync(flags: .barrier) {__autoBlackEnabled = newValue }}}
  var _autoBlackLevel: UInt32 {
    get { Api.objectQ.sync { __autoBlackLevel } }
    set { Api.objectQ.sync(flags: .barrier) { __autoBlackLevel = newValue }}}
  var _blackLevel: Int {
    get { Api.objectQ.sync { __blackLevel } }
    set { Api.objectQ.sync(flags: .barrier) {__blackLevel = newValue }}}
  var _clientHandle: Handle {          // (V3 only)
    get { Api.objectQ.sync { __clientHandle } }
    set { Api.objectQ.sync(flags: .barrier) { __clientHandle = newValue }}}
  var _colorGain: Int {
    get { Api.objectQ.sync { __colorGain } }
    set { Api.objectQ.sync(flags: .barrier) {__colorGain = newValue }}}
  var _gradientIndex: Int {
    get { Api.objectQ.sync { __gradientIndex } }
    set { Api.objectQ.sync(flags: .barrier) {__gradientIndex = newValue }}}
  var _lineDuration: Int {
    get { Api.objectQ.sync { __lineDuration } }
    set { Api.objectQ.sync(flags: .barrier) {__lineDuration = newValue }}}
  var _panadapterId: PanadapterStreamId {
    get { Api.objectQ.sync { __panadapterId } }
    set { Api.objectQ.sync(flags: .barrier) { __panadapterId = newValue }}}

  
  enum Token : String {
    // on Waterfall
    case autoBlackEnabled     = "auto_black"
    case blackLevel           = "black_level"
    case clientHandle         = "client_handle"
    case colorGain            = "color_gain"
    case gradientIndex        = "gradient_index"
    case lineDuration         = "line_duration"
    // unused here
    case available
    case band
    case bandZoomEnabled      = "band_zoom"
    case bandwidth
    case capacity
    case center
    case daxIq                = "daxiq"
    case daxIqChannel         = "daxiq_channel"
    case daxIqRate            = "daxiq_rate"
    case loopA                = "loopa"
    case loopB                = "loopb"
    case panadapterId         = "panadapter"
    case rfGain               = "rfgain"
    case rxAnt                = "rxant"
    case segmentZoomEnabled   = "segment_zoom"
    case wide
    case xPixels              = "x_pixels"
    case xvtr
  }

  // ----------------------------------------------------------------------------
  // MARK: - Private properties
  
  private var _index              = 0
  private var _initialized        = false
  private let _log                = Log.sharedInstance.logMessage
  private let _numberOfDataFrames = 10
  private let _radio              : Radio
  private var _waterfallframes    = [WaterfallFrame]()
  
  // ----------------------------------------------------------------------------
  // MARK: - Initialization
  
  /// Initialize a Waterfall
  ///
  /// - Parameters:
  ///   - radio:        the Radio instance
  ///   - id:           a Waterfall Id
  ///
  public init(radio: Radio, id: WaterfallStreamId) {
    
    _radio = radio
    self.id = id
    
    // allocate two dataframes
    for _ in 0..<_numberOfDataFrames {
      _waterfallframes.append(WaterfallFrame(frameSize: 4096))
    }
    super.init()
    
    isStreaming = false
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Class methods
  
  /// Parse a Waterfall status message
  ///
  ///   StatusParser protocol method, executes on the parseQ
  ///
  /// - Parameters:
  ///   - keyValues:      a KeyValuesArray
  ///   - radio:          the current Radio class
  ///   - queue:          a parse Queue for the object
  ///   - inUse:          false = "to be deleted"
  ///
  class func parseStatus(_ radio: Radio, _ properties: KeyValuesArray, _ inUse: Bool = true) {
    // Format: <"waterfall", ""> <streamId, ""> <"x_pixels", value> <"center", value> <"bandwidth", value> <"line_duration", value>
    //          <"rfgain", value> <"rxant", value> <"wide", 1|0> <"loopa", 1|0> <"loopb", 1|0> <"band", value> <"daxiq", value>
    //          <"daxiq_rate", value> <"capacity", value> <"available", value> <"panadapter", streamId>=40000000 <"color_gain", value>
    //          <"auto_black", 1|0> <"black_level", value> <"gradient_index", value> <"xvtr", value>
    //      OR
    // Format: <"waterfall", ""> <streamId, ""> <"rxant", value> <"loopa", 1|0> <"loopb", 1|0>
    //      OR
    // Format: <"waterfall", ""> <streamId, ""> <"rfgain", value>
    //      OR
    // Format: <"waterfall", ""> <streamId, ""> <"daxiq", value> <"daxiq_rate", value> <"capacity", value> <"available", value>
    
    // get the Id
    if let id = properties[1].key.streamId {
      
      // is the object in use?
      if inUse {
        
        // YES, does it exist?
        if radio.waterfalls[id] == nil {
          
          // Create a Waterfall & add it to the Waterfalls collection
          radio.waterfalls[id] = Waterfall(radio: radio, id: id)
        }
        // pass the key values to the Waterfall for parsing (dropping the Type and Id)
        radio.waterfalls[id]!.parseProperties(radio, Array(properties.dropFirst(2)))
        
      } else {
        
        // does it exist?
        if radio.waterfalls[id] != nil {
          
          // YES, remove the Panadapter & Waterfall, notify all observers
          let panadapterId = radio.waterfalls[id]!.panadapterId
                    
          radio.panadapters[panadapterId] = nil
          
          Log.sharedInstance.logMessage("Panadapter removed: id = \(panadapterId.hex)", .debug, #function, #file, #line)

          NC.post(.panadapterHasBeenRemoved, object: id as Any?)

          NC.post(.waterfallWillBeRemoved, object: radio.waterfalls[id] as Any?)
                    
          radio.waterfalls[id] = nil
          
          Log.sharedInstance.logMessage("Waterfall removed: id = \(id.hex)", .debug, #function, #file, #line)
          
          NC.post(.waterfallHasBeenRemoved, object: id as Any?)
        }
      }
    }
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Instance methods
  
  /// Parse Waterfall key/value pairs
  ///
  ///   PropertiesParser protocol method, executes on the parseQ
  ///
  /// - Parameter properties:       a KeyValuesArray
  ///
  func parseProperties(_ radio: Radio, _ properties: KeyValuesArray) {
    
    // process each key/value pair, <key=value>
    for property in properties {
      
      // check for unknown Keys
      guard let token = Token(rawValue: property.key) else {
        // log it and ignore the Key
        _log("Unknown Waterfall token: \(property.key) = \(property.value)", .warning, #function, #file, #line)
        continue
      }
      // Known keys, in alphabetical order
      switch token {
        
      case .autoBlackEnabled: willChangeValue(for: \.autoBlackEnabled)  ; _autoBlackEnabled = property.value.bValue     ; didChangeValue(for: \.autoBlackEnabled)
      case .blackLevel:       willChangeValue(for: \.blackLevel)        ; _blackLevel = property.value.iValue           ; didChangeValue(for: \.blackLevel)
      case .clientHandle:     willChangeValue(for: \.clientHandle)      ; _clientHandle = property.value.handle ?? 0    ; didChangeValue(for: \.clientHandle)
      case .colorGain:        willChangeValue(for: \.colorGain)         ; _colorGain = property.value.iValue            ; didChangeValue(for: \.colorGain)
      case .gradientIndex:    willChangeValue(for: \.gradientIndex)     ; _gradientIndex = property.value.iValue        ; didChangeValue(for: \.gradientIndex)
      case .lineDuration:     willChangeValue(for: \.lineDuration)      ; _lineDuration = property.value.iValue         ; didChangeValue(for: \.lineDuration)
      case .panadapterId:     willChangeValue(for: \.panadapterId)      ; _panadapterId = property.value.streamId ?? 0  ; didChangeValue(for: \.panadapterId)
      case .available, .band, .bandwidth, .bandZoomEnabled, .capacity, .center, .daxIq, .daxIqChannel,
           .daxIqRate, .loopA, .loopB, .rfGain, .rxAnt, .segmentZoomEnabled, .wide, .xPixels, .xvtr:  break   // ignored here
      }
    }
    // is the waterfall initialized?
    if !_initialized && panadapterId != 0 {
      
      // YES, the Radio (hardware) has acknowledged this Waterfall
      _initialized = true
      
      _log("Waterfall added: id = \(id.hex)", .debug, #function, #file, #line)

      // notify all observers
      NC.post(.waterfallHasBeenAdded, object: self as Any?)
    }
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Stream methods
  
  /// Process the Waterfall Vita struct
  ///
  ///   VitaProcessor protocol method, executes on the streamQ
  ///      The payload of the incoming Vita struct is converted to a WaterfallFrame and
  ///      passed to the Waterfall Stream Handler, called by Radio
  ///
  /// - Parameters:
  ///   - vita:       a Vita struct
  ///
  func vitaProcessor(_ vita: Vita) {
    
    // convert the Vita struct and accumulate a WaterfallFrame
    if _waterfallframes[_index].accumulate(version: _radio.version, vita: vita, expectedFrame: &packetFrame) {

      // save the auto black level
      _autoBlackLevel = _waterfallframes[_index].autoBlackLevel
      
      // Pass the data frame to this Waterfall's delegate
      delegate?.streamHandler(_waterfallframes[_index])

      // use the next dataframe
      _index = (_index + 1) % _numberOfDataFrames
    }
  }

  // ----------------------------------------------------------------------------
  // MARK: - Private methods
  
  /// Send a command to Set a Waterfall property
  ///
  /// - Parameters:
  ///   - token:      the parse token
  ///   - value:      the new value
  ///
  private func waterfallCmd(_ token: Token, _ value: Any) {
    _radio.sendCommand("display panafall set " + "\(id.hex) " + token.rawValue + "=\(value)")
  }
  
  // ----------------------------------------------------------------------------
  // *** Hidden properties (Do NOT use) ***
  
  private var _delegate           : StreamHandler? = nil
  
  private var __autoBlackEnabled  = false
  private var __autoBlackLevel    : UInt32 = 0
  private var __blackLevel        = 0
  private var __clientHandle      : Handle = 0
  private var __colorGain         = 0
  private var __daxIqChannel      = 0
  private var __gradientIndex     = 0
  private var __lineDuration      = 0
  private var __panadapterId      : PanadapterStreamId = 0
}

/// Class containing Waterfall Stream data
///
///   populated by the Waterfall vitaHandler
///
public class WaterfallFrame {
  
  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  
  public private(set) var firstBinFreq      : CGFloat   = 0.0               // Frequency of first Bin (Hz)
  public private(set) var binBandwidth      : CGFloat   = 0.0               // Bandwidth of a single bin (Hz)
  public private(set) var lineDuration      = 0                             // Duration of this line (ms)
  public private(set) var numberOfBins      = 0                             // Number of bins
  public private(set) var height            = 0                             // Height of frame (pixels)
  public private(set) var receivedFrame     = 0                             // Time code
  public private(set) var autoBlackLevel    : UInt32 = 0                    // Auto black level
  public private(set) var totalBins         = 0                             //
  public private(set) var startingBin       = 0                             //
  public var bins                           = [UInt16]()                    // Array of bin values
  
  // ----------------------------------------------------------------------------
  // MARK: - Private properties
  
  private var _binsProcessed                = 0
  private var _byteOffsetToBins             = 0
  private var _log                          = Log.sharedInstance.logMessage
  
  private struct PayloadHeaderOld {                                         // struct to mimic payload layout
    var firstBinFreq                        : UInt64                        // 8 bytes
    var binBandwidth                        : UInt64                        // 8 bytes
    var lineDuration                        : UInt32                        // 4 bytes
    var numberOfBins                        : UInt16                        // 2 bytes
    var lineHeight                          : UInt16                        // 2 bytes
    var receivedFrame                       : UInt32                        // 4 bytes
    var autoBlackLevel                      : UInt32                        // 4 bytes
  }
  
  private struct PayloadHeader {                                            // struct to mimic payload layout
    var firstBinFreq                        : UInt64                        // 8 bytes
    var binBandwidth                        : UInt64                        // 8 bytes
    var lineDuration                        : UInt32                        // 4 bytes
    var numberOfBins                        : UInt16                        // 2 bytes
    var height                              : UInt16                        // 2 bytes
    var receivedFrame                       : UInt32                        // 4 bytes
    var autoBlackLevel                      : UInt32                        // 4 bytes
    var totalBins                           : UInt16                        // 2 bytes
    var firstBin                            : UInt16                        // 2 bytes
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Initialization
  
  /// Initialize a WaterfallFrame
  ///
  /// - Parameter frameSize:    max number of Waterfall samples
  ///
  public init(frameSize: Int) {
    
    // allocate the bins array
    self.bins = [UInt16](repeating: 0, count: frameSize)
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Public methods
  
  /// Accumulate Vita object(s) into a WaterfallFrame
  ///
  /// - Parameter vita:         incoming Vita object
  /// - Returns:                true if entire frame processed
  ///
  public func accumulate(version: Version, vita: Vita, expectedFrame: inout Int) -> Bool {
    
    let payloadPtr = UnsafeRawPointer(vita.payloadData)
    
    if version.isGreaterThanV22 {
      // 2.3.x or greater
      // map the payload to the New Payload struct
      let p = payloadPtr.bindMemory(to: PayloadHeader.self, capacity: 1)
      
      // 2.3.x or greater
      // Bins are just beyond the payload
      _byteOffsetToBins = MemoryLayout<PayloadHeader>.size
      
      // byte swap and convert each payload component
      firstBinFreq = CGFloat(CFSwapInt64BigToHost(p.pointee.firstBinFreq)) / 1.048576E6
      binBandwidth = CGFloat(CFSwapInt64BigToHost(p.pointee.binBandwidth)) / 1.048576E6
      lineDuration = Int( CFSwapInt32BigToHost(p.pointee.lineDuration) )
      numberOfBins = Int( CFSwapInt16BigToHost(p.pointee.numberOfBins) )
      height = Int( CFSwapInt16BigToHost(p.pointee.height) )
      receivedFrame = Int( CFSwapInt32BigToHost(p.pointee.receivedFrame) )
      autoBlackLevel = CFSwapInt32BigToHost(p.pointee.autoBlackLevel)
      totalBins = Int( CFSwapInt16BigToHost(p.pointee.totalBins) )
      startingBin = Int( CFSwapInt16BigToHost(p.pointee.firstBin) )
      
    } else {
      // pre 2.3.x
      // map the payload to the Old Payload struct
      let p = payloadPtr.bindMemory(to: PayloadHeaderOld.self, capacity: 1)
      
      // pre 2.3.x
      // Bins are just beyond the payload
      _byteOffsetToBins = MemoryLayout<PayloadHeaderOld>.size
      
      // byte swap and convert each payload component
      firstBinFreq = CGFloat(CFSwapInt64BigToHost(p.pointee.firstBinFreq)) / 1.048576E6
      binBandwidth = CGFloat(CFSwapInt64BigToHost(p.pointee.binBandwidth)) / 1.048576E6
      lineDuration = Int( CFSwapInt32BigToHost(p.pointee.lineDuration) )
      numberOfBins = Int( CFSwapInt16BigToHost(p.pointee.numberOfBins) )
      height = Int( CFSwapInt16BigToHost(p.pointee.lineHeight) )
      receivedFrame = Int( CFSwapInt32BigToHost(p.pointee.receivedFrame) )
      autoBlackLevel = CFSwapInt32BigToHost(p.pointee.autoBlackLevel)
      totalBins = numberOfBins
      startingBin = 0
    }
    // initial frame?
    if expectedFrame == -1 { expectedFrame = receivedFrame }
    
    switch (expectedFrame, receivedFrame) {
      
    case (let expected, let received) where received < expected:
      // from a previous group, ignore it
      _log("Waterfall ignored frame(s): expected = \(expected), received = \(received)", .warning, #function, #file, #line)
      return false
      
    case (let expected, let received) where received > expected:
      // from a later group, jump forward
      _log("Waterfall missing frame(s): expected = \(expected), received = \(received)", .warning, #function, #file, #line)
      expectedFrame = received
      fallthrough
      
    default:
      // received == expected
      // get a pointer to the Bins in the payload
      let binsPtr = payloadPtr.advanced(by: _byteOffsetToBins).bindMemory(to: UInt16.self, capacity: numberOfBins)
      
      // Swap the byte ordering of the data & place it in the bins
      for i in 0..<numberOfBins {
        bins[i+startingBin] = CFSwapInt16BigToHost( binsPtr.advanced(by: i).pointee )
      }

      // reset the count if the entire frame has been accumulated
      if startingBin + numberOfBins == totalBins { numberOfBins = totalBins  ; expectedFrame += 1 }
    }
    // return true if the entire frame has been accumulated
    return numberOfBins == totalBins
  }
}
