//
//  Memory.swift
//  xLib6000
//
//  Created by Douglas Adams on 8/20/15.
//  Copyright © 2015 Douglas Adams. All rights reserved.
//

import Foundation

public typealias MemoryId = String

/// Memory Class implementation
///
///      creates a Memory instance to be used by a Client to support the
///      processing of a Memory. Memory objects are added, removed and
///      updated by the incoming TCP messages. They are collected in the
///      memories collection on the Radio object.
///
public final class Memory                   : NSObject, DynamicModel {
  
  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  
  public let id                             : MemoryId                  // Id that uniquely identifies this Memory
  
  @objc dynamic public var digitalLowerOffset: Int {
    get { _digitalLowerOffset }
    set { if _digitalLowerOffset != newValue { _digitalLowerOffset = newValue ; memCmd( .digitalLowerOffset, newValue) }}}
  @objc dynamic public var digitalUpperOffset: Int {
    get { _digitalUpperOffset }
    set { if _digitalUpperOffset != newValue { _digitalUpperOffset = newValue ; memCmd( .digitalUpperOffset, newValue) }}}
  @objc dynamic public var filterHigh: Int {
    get { _filterHigh }
    set { let value = filterHighLimits(newValue) ; if _filterHigh != value { _filterHigh = value ; memCmd( .rxFilterHigh, newValue) }}}
  @objc dynamic public var filterLow: Int {
    get { _filterLow }
    set { let value = filterLowLimits(newValue) ; if _filterLow != value { _filterLow = value ; memCmd( .rxFilterLow, newValue) }}}
  @objc dynamic public var frequency: Hz {
    get { _frequency }
    set { if _frequency != newValue { _frequency = newValue ; memCmd( .frequency, newValue) }}}
  @objc dynamic public var group: String {
    get { _group }
    set { let value = newValue.replacingSpaces() ; if _group != value { _group = value ; memCmd( .group, newValue) }}}
  @objc dynamic public var mode: String {
    get { _mode }
    set { if _mode != newValue { _mode = newValue ; memCmd( .mode, newValue) }}}
  @objc dynamic public var name: String {
    get { _name }
    set { let value = newValue.replacingSpaces() ; if _name != value { _name = newValue ; memCmd( .name, newValue) }}}
  @objc dynamic public var offset: Int {
    get { _offset }
    set { if _offset != newValue { _offset = newValue ; memCmd( .repeaterOffset, newValue) }}}
  @objc dynamic public var offsetDirection: String {
    get { _offsetDirection }
    set { if _offsetDirection != newValue { _offsetDirection = newValue ; memCmd( .repeaterOffsetDirection, newValue) }}}
  @objc dynamic public var owner: String {
    get { _owner }
    set { let value = newValue.replacingSpaces() ; if _owner != value { _owner = newValue ; memCmd( .owner, newValue) }}}
  @objc dynamic public var rfPower: Int {
    get { _rfPower }
    set { if _rfPower != newValue { _rfPower = newValue ; memCmd( .rfPower, newValue) }}}
  @objc dynamic public var rttyMark: Int {
    get { _rttyMark }
    set { if _rttyMark != newValue { _rttyMark = newValue ; memCmd( .rttyMark, newValue) }}}
  @objc dynamic public var rttyShift: Int {
    get { _rttyShift }
    set { if _rttyShift != newValue { _rttyShift = newValue ; memCmd( .rttyShift, newValue) }}}
  @objc dynamic public var squelchEnabled: Bool {
    get { _squelchEnabled }
    set { if _squelchEnabled != newValue { _squelchEnabled = newValue ; memCmd( .squelchEnabled, newValue.as1or0) }}}
  @objc dynamic public var squelchLevel: Int {
    get { _squelchLevel }
    set { if _squelchLevel != newValue { _squelchLevel = newValue ; memCmd( .squelchLevel, newValue) }}}
  @objc dynamic public var step: Int {
    get { _step }
    set { if _step != newValue { _step = newValue ; memCmd( .step, newValue) }}}
  @objc dynamic public var toneMode: String {
    get { _toneMode }
    set { if _toneMode != newValue { _toneMode = newValue ; memCmd( .toneMode, newValue) }}}
  @objc dynamic public var toneValue: Int {
    get { _toneValue }
    set { if _toneValue != newValue { _toneValue = newValue ; memCmd( .toneValue, newValue) } } }

  public enum TXOffsetDirection : String {
    case down
    case simplex
    case up
  }
  public enum ToneMode : String {
    case ctcssTx = "ctcss_tx"
    case off
  }

  // ----------------------------------------------------------------------------
  // MARK: - Internal properties
  
  var _digitalLowerOffset: Int {
    get { Api.objectQ.sync { __digitalLowerOffset } }
    set { Api.objectQ.sync(flags: .barrier) { __digitalLowerOffset = newValue }}}
  var _digitalUpperOffset: Int {
    get { Api.objectQ.sync { __digitalUpperOffset } }
    set { Api.objectQ.sync(flags: .barrier) { __digitalUpperOffset = newValue }}}
  var _filterHigh: Int {
    get { Api.objectQ.sync { __filterHigh } }
    set { Api.objectQ.sync(flags: .barrier) { __filterHigh = newValue }}}
  var _filterLow: Int {
    get { Api.objectQ.sync { __filterLow } }
    set { Api.objectQ.sync(flags: .barrier) { __filterLow = newValue }}}
  var _frequency: Int {
    get { Api.objectQ.sync { __frequency } }
    set { Api.objectQ.sync(flags: .barrier) { __frequency = newValue }}}
  var _group: String {
    get { Api.objectQ.sync { __group } }
    set { Api.objectQ.sync(flags: .barrier) { __group = newValue }}}
  var _mode: String {
    get { Api.objectQ.sync { __mode } }
    set { Api.objectQ.sync(flags: .barrier) { __mode = newValue }}}
  var _name: String {
    get { Api.objectQ.sync { __name } }
    set { Api.objectQ.sync(flags: .barrier) { __name = newValue }}}
  var _offset: Int {
    get { Api.objectQ.sync { __offset } }
    set { Api.objectQ.sync(flags: .barrier) { __offset = newValue }}}
  var _offsetDirection: String {
    get { Api.objectQ.sync { __offsetDirection } }
    set { Api.objectQ.sync(flags: .barrier) { __offsetDirection = newValue }}}
  var _owner: String {
    get { Api.objectQ.sync { __owner } }
    set { Api.objectQ.sync(flags: .barrier) { __owner = newValue }}}
  var _rfPower: Int {
    get { Api.objectQ.sync { __rfPower } }
    set { Api.objectQ.sync(flags: .barrier) { __rfPower = newValue }}}
  var _rttyMark: Int {
    get { Api.objectQ.sync { __rttyMark } }
    set { Api.objectQ.sync(flags: .barrier) { __rttyMark = newValue }}}
  var _rttyShift: Int {
    get { Api.objectQ.sync { __rttyShift } }
    set { Api.objectQ.sync(flags: .barrier) { __rttyShift = newValue }}}
  var _squelchEnabled: Bool {
    get { Api.objectQ.sync { __squelchEnabled } }
    set { Api.objectQ.sync(flags: .barrier) { __squelchEnabled = newValue }}}
  var _squelchLevel: Int {
    get { Api.objectQ.sync { __squelchLevel } }
    set { Api.objectQ.sync(flags: .barrier) { __squelchLevel = newValue }}}
  var _step: Int {
    get { Api.objectQ.sync { __step } }
    set { Api.objectQ.sync(flags: .barrier) { __step = newValue }}}
  var _toneMode: String {
    get { Api.objectQ.sync { __toneMode } }
    set { Api.objectQ.sync(flags: .barrier) { __toneMode = newValue }}}
  var _toneValue: Int {
    get {  Api.objectQ.sync { __toneValue } }
    set { Api.objectQ.sync(flags: .barrier) { __toneValue = newValue }}}

  enum Token : String {
    case digitalLowerOffset                 = "digl_offset"
    case digitalUpperOffset                 = "digu_offset"
    case frequency                          = "freq"
    case group
    case highlight
    case highlightColor                     = "highlight_color"
    case mode
    case name
    case owner
    case repeaterOffsetDirection            = "repeater"
    case repeaterOffset                     = "repeater_offset"
    case rfPower                            = "power"
    case rttyMark                           = "rtty_mark"
    case rttyShift                          = "rtty_shift"
    case rxFilterHigh                       = "rx_filter_high"
    case rxFilterLow                        = "rx_filter_low"
    case step
    case squelchEnabled                     = "squelch"
    case squelchLevel                       = "squelch_level"
    case toneMode                           = "tone_mode"
    case toneValue                          = "tone_value"
  }

  // ------------------------------------------------------------------------------
  // MARK: - Private properties
  
  private var _initialized                  = false
  private let _log                          = Log.sharedInstance.msg
  private var _radio                        : Radio

  // ------------------------------------------------------------------------------
  // MARK: - Class methods
  
  /// Parse a Memory status message
  ///   Format:
  ///
  ///   StatusParser protocol method, executes on the parseQ
  ///
  /// - Parameters:
  ///   - keyValues:      a KeyValuesArray
  ///   - radio:          the current Radio class
  ///   - queue:          a parse Queue for the object
  ///   - inUse:          false = "to be deleted"
  ///
  class func parseStatus(_ radio: Radio, _ keyValues: KeyValuesArray, _ inUse: Bool = true) {
    var memory: Memory?
    
    // get the Memory Id
    let memoryId = keyValues[0].key
    
    // is the Memory in use?
    if inUse {
      
      // YES, does it exist?
      memory = radio.memories[memoryId]
      if memory == nil {
        
        // NO, create a new Memory & add it to the Memories collection
        memory = Memory(radio: radio, id: memoryId)
        radio.memories[memoryId] = memory
      }
      // pass the key values to the Memory for parsing (dropping the Id)
      memory!.parseProperties(radio, Array(keyValues.dropFirst(1)) )
      
    } else {
      
      // NO, notify all observers
      NC.post(.memoryWillBeRemoved, object: radio.memories[memoryId] as Any?)
      
      // remove it
      radio.memories[memoryId] = nil
    }
  }

  // ------------------------------------------------------------------------------
  // MARK: - Initialization
  
  /// Initialize a Memory
  ///
  /// - Parameters:
  ///   - radio:        the Radio instance
  ///   - id:           a Memory Id
  ///
  init(radio: Radio, id: MemoryId) {
    
    _radio = radio
    self.id = id
    super.init()
  }
  
  // ------------------------------------------------------------------------------
  // MARK: - Instance methods
  
  /// Restrict the Filter High value
  ///
  /// - Parameters:
  ///   - value:          the value
  /// - Returns:          adjusted value
  ///
  func filterHighLimits(_ value: Int) -> Int {
    
    var newValue = (value < filterHigh + 10 ? filterHigh + 10 : value)
    
    if let modeType = xLib6000.Slice.Mode(rawValue: mode.lowercased()) {
      switch modeType {
        
      case .CW:
        newValue = (newValue > 12_000 - _radio.transmit.cwPitch ? 12_000 - _radio.transmit.cwPitch : newValue)
        
      case .RTTY:
        newValue = (newValue > 4_000 ? 4_000 : newValue)
        
      case .AM, .SAM, .FM, .NFM, .DFM:
        newValue = (newValue > 12_000 ? 12_000 : newValue)
        newValue = (newValue < 10 ? 10 : newValue)
        
      case .LSB, .DIGL:
        newValue = (newValue > 0 ? 0 : newValue)
        
      case .USB, .DIGU:
        newValue = (newValue > 12_000 ? 12_000 : newValue)
      }
    }
    return newValue
  }
  /// Restrict the Filter Low value
  ///
  /// - Parameters:
  ///   - value:          the value
  /// - Returns:          adjusted value
  ///
  func filterLowLimits(_ value: Int) -> Int {
    
    var newValue = (value > filterHigh - 10 ? filterHigh - 10 : value)
    
    if let modeType = xLib6000.Slice.Mode(rawValue: mode.lowercased()) {
      switch modeType {
        
      case .CW:
        newValue = (newValue < -12_000 - _radio.transmit.cwPitch ? -12_000 - _radio.transmit.cwPitch : newValue)
        
      case .RTTY:
        newValue = (newValue < -12_000 ? -12_000 : newValue)
        
      case .AM, .SAM, .FM, .NFM, .DFM:
        newValue = (newValue < -12_000 ? -12_000 : newValue)
        newValue = (newValue > -10 ? -10 : newValue)
        
      case .LSB, .DIGL:
        newValue = (newValue < -12_000 ? -12_000 : newValue)
        
      case .USB, .DIGU:
        newValue = (newValue < 0 ? 0 : newValue)
      }
    }
    return newValue
  }
  /// Validate the Tone Value
  ///
  /// - Parameters:
  ///   - value:          a Tone Value
  /// - Returns:          true = Valid
  ///
  func toneValueValid( _ value: Int) -> Bool {
    
    return toneMode == ToneMode.ctcssTx.rawValue && toneValue.within(0, 301)
  }
  /// Parse Memory key/value pairs
  ///
  ///   PropertiesParser Protocol method, executes on the parseQ
  ///
  /// - Parameter properties:       a KeyValuesArray
  ///
  func parseProperties(_ radio: Radio, _ properties: KeyValuesArray)  {
    
    // process each key/value pair, <key=value>
    for property in properties {
      
      // Check for Unknown Keys
      guard let token = Token(rawValue: property.key) else {
        // log it and ignore the Key
        _log("Unknown Memory token: \(property.key) = \(property.value)", .warning, #function, #file, #line)
        continue
      }
      // Known tokens, in alphabetical order
      switch (token) {
        
      case .digitalLowerOffset:       update(self, &_digitalLowerOffset,  to: property.value.iValue,                    signal: \.digitalLowerOffset)
      case .digitalUpperOffset:       update(self, &_digitalUpperOffset,  to: property.value.iValue,                    signal: \.digitalUpperOffset)
      case .frequency:                update(self, &_frequency,           to: property.value.mhzToHz,                   signal: \.frequency)
      case .group:                    update(self, &_group,               to: property.value.replacingSpaces(),         signal: \.group)
      case .highlight:                break // not implemented
      case .highlightColor:           break // not implemented
      case .mode:                     update(self, &_mode,                to: property.value.replacingSpaces(),         signal: \.mode)
      case .name:                     update(self, &_name,                to: property.value.replacingSpaces(),         signal: \.name)
      case .owner:                    update(self, &_owner,               to: property.value.replacingSpaces(),         signal: \.owner)
      case .repeaterOffsetDirection:  update(self, &_offsetDirection,     to: property.value.replacingSpaces(),         signal: \.offsetDirection)
      case .repeaterOffset:           update(self, &_offset,              to: property.value.iValue,                    signal: \.offset)
      case .rfPower:                  update(self, &_rfPower,             to: property.value.iValue,                    signal: \.rfPower)
      case .rttyMark:                 update(self, &_rttyMark,            to: property.value.iValue,                    signal: \.rttyMark)
      case .rttyShift:                update(self, &_rttyShift,           to: property.value.iValue,                    signal: \.rttyShift)
      case .rxFilterHigh:             update(self, &_filterHigh,          to: filterHighLimits(property.value.iValue),  signal: \.filterHigh)
      case .rxFilterLow:              update(self, &_filterLow,           to: filterLowLimits(property.value.iValue),   signal: \.filterLow)
      case .squelchEnabled:           update(self, &_squelchEnabled,      to: property.value.bValue,                    signal: \.squelchEnabled)
      case .squelchLevel:             update(self, &_squelchLevel,        to: property.value.iValue,                    signal: \.squelchLevel)
      case .step:                     update(self, &_step,                to: property.value.iValue,                    signal: \.step)
      case .toneMode:                 update(self, &_toneMode,            to: property.value.replacingSpaces(),         signal: \.toneMode)
      case .toneValue:                update(self, &_toneValue,           to: property.value.iValue,                    signal: \.toneValue)
      }
    }
    // is the Memory initialized?
    if !_initialized  {
      
      // YES, the Radio (hardware) has acknowledged this Memory
      _initialized = true
      
      // notify all observers
      NC.post(.memoryHasBeenAdded, object: self as Any?)
    }
  }
  /// Apply a Memory
  ///
  /// - Parameter callback:   ReplyHandler (optional)
  ///
  public func apply(callback: ReplyHandler? = nil) {
    
    // tell the Radio to apply the Memory
    _radio.sendCommand("memory apply " + "\(id)", replyTo: callback)
  }
  /// Remove a Memory
  ///
  /// - Parameters:
  ///   - callback:           ReplyHandler (optional)
  ///
  public func remove(callback: ReplyHandler? = nil) {
    
    // tell the Radio to remove the Memory
    _radio.sendCommand("memory remove " + "\(id)", replyTo: callback)
    
    // notify all observers
    NC.post(.memoryWillBeRemoved, object: self as Any?)
  }
  /// Select a Memory
  ///
  public func select() {
    
    _radio.sendCommand("memory apply " + "\(id)")
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Private methods

  /// Set a Memory property on the Radio
  ///
  /// - Parameters:
  ///   - token:      the parse token
  ///   - value:      the new value
  ///
  private func memCmd(_ token: Token, _ value: Any) {
    _radio.sendCommand("memory set " + "\(id) " + token.rawValue + "=\(value)")
  }
  
  // ----------------------------------------------------------------------------
  // *** Hidden properties (Do NOT use) ***
  
  private var __digitalLowerOffset          = 0
  private var __digitalUpperOffset          = 0
  private var __filterHigh                  = 0
  private var __filterLow                   = 0
  private var __frequency                   : Hz = 0
  private var __group                       = ""
  private var __mode                        = ""
  private var __name                        = ""
  private var __offset                      : Hz = 0
  private var __offsetDirection             = ""
  private var __owner                       = ""
  private var __rfPower                     = 0
  private var __rttyMark                    = 0
  private var __rttyShift                   = 0
  private var __squelchEnabled              = false
  private var __squelchLevel                = 0
  private var __step                        = 0
  private var __toneMode                    = ""
  private var __toneValue                   : Hz = 0
}