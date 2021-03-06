//
//  xLib6000.Slice.swift
//  xLib6000
//
//  Created by Douglas Adams on 6/2/15.
//  Copyright (c) 2015 Douglas Adams, K3TZR
//

import Foundation

public typealias SliceId  = ObjectId
public typealias Hz       = Int

/// Slice Class implementation
///
///      creates a Slice instance to be used by a Client to support the
///      rendering of a Slice. Slice objects are added, removed and
///      updated by the incoming TCP messages. They are collected in the
///      slices collection on the Radio object.
///
public final class Slice  : NSObject, DynamicModel {
  
  
  // ----------------------------------------------------------------------------
  // MARK: - Static properties
  
  static let kMinOffset                     = -99_999      // frequency offset range
  static let kMaxOffset                     = 99_999
  
  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  
  public                let id              : SliceId

  @objc dynamic public var active: Bool {
    get { _active }
    set { if _active != newValue { _active = newValue ; sliceCmd( .active, newValue.as1or0) }}}
  @objc dynamic public var agcMode: String {
    get { _agcMode }
    set { if _agcMode != newValue { _agcMode = newValue ; sliceCmd( .agcMode, newValue) }}}
  @objc dynamic public var agcOffLevel: Int {
    get { _agcOffLevel }
    set { if _agcOffLevel != newValue {  _agcOffLevel = newValue ; sliceCmd( .agcOffLevel, newValue) }}}
  @objc dynamic public var agcThreshold: Int {
    get { _agcThreshold }
    set { if _agcThreshold != newValue { _agcThreshold = newValue ; sliceCmd( .agcThreshold, newValue) }}}
  @objc dynamic public var anfEnabled: Bool {
    get { _anfEnabled }
    set { if _anfEnabled != newValue { _anfEnabled = newValue ; sliceCmd( .anfEnabled, newValue.as1or0) }}}
  @objc dynamic public var anfLevel: Int {
    get { _anfLevel }
    set { if _anfLevel != newValue { _anfLevel = newValue ; sliceCmd( .anfLevel, newValue) }}}
  @objc dynamic public var apfEnabled: Bool {
    get { _apfEnabled }
    set { if _apfEnabled != newValue { _apfEnabled = newValue ; sliceCmd( .apfEnabled, newValue.as1or0) }}}
  @objc dynamic public var apfLevel: Int {
    get { _apfLevel }
    set { if _apfLevel != newValue { _apfLevel = newValue ; sliceCmd( .apfLevel, newValue) }}}
  @objc dynamic public var audioGain: Int {
    get { _audioGain }
    set { if _audioGain != newValue { _audioGain = newValue ; audioCmd("gain", value: newValue) }}}
  @objc dynamic public var audioLevel: Int {
    get { _audioLevel }
    set { if _audioLevel != newValue { _audioLevel = newValue ; audioCmd(.audioLevel, value: newValue) }}}
  @objc dynamic public var audioMute: Bool {
    get { _audioMute }
    set { if _audioMute != newValue { _audioMute = newValue ; audioCmd("mute", value: newValue.as1or0) }}}
  @objc dynamic public var audioPan: Int {
    get { _audioPan }
    set { if _audioPan != newValue { _audioPan = newValue ; audioCmd("pan", value: newValue) }}}
  @objc dynamic public var daxChannel: Int {
    get { _daxChannel }
    set { if _daxChannel != newValue { _daxChannel = newValue ; sliceCmd(.daxChannel, newValue) }}}
  @objc dynamic public var dfmPreDeEmphasisEnabled: Bool {
    get { _dfmPreDeEmphasisEnabled }
    set { if _dfmPreDeEmphasisEnabled != newValue { _dfmPreDeEmphasisEnabled = newValue ; sliceCmd(.dfmPreDeEmphasisEnabled, newValue.as1or0) }}}
  @objc dynamic public var digitalLowerOffset: Int {
    get { _digitalLowerOffset }
    set { if _digitalLowerOffset != newValue { _digitalLowerOffset = newValue ; sliceCmd(.digitalLowerOffset, newValue) }}}
  @objc dynamic public var digitalUpperOffset: Int {
    get { _digitalUpperOffset }
    set { if _digitalUpperOffset != newValue { _digitalUpperOffset = newValue ; sliceCmd(.digitalUpperOffset, newValue) }}}
  @objc dynamic public var diversityEnabled: Bool {
    get { _diversityEnabled }
    set { if _diversityEnabled != newValue { _diversityEnabled = newValue ; sliceCmd(.diversityEnabled, newValue.as1or0) }}}
  @objc dynamic public var filterHigh: Int {
    get { _filterHigh }
    set { if _filterHigh != newValue { let value = filterHighLimits(newValue) ; _filterHigh = value ; filterCmd( low: _filterLow, high: value) }}}
  @objc dynamic public var filterLow: Int {
    get { _filterLow }
    set { if _filterLow != newValue { let value = filterLowLimits(newValue) ; _filterLow = value ; filterCmd( low: value, high: _filterHigh) }}}
  @objc dynamic public var fmDeviation: Int {
    get { _fmDeviation }
    set { if _fmDeviation != newValue { _fmDeviation = newValue ; sliceCmd(.fmDeviation, newValue) }}}
  @objc dynamic public var fmRepeaterOffset: Float {
    get { _fmRepeaterOffset }
    set { if _fmRepeaterOffset != newValue { _fmRepeaterOffset = newValue ; sliceCmd( .fmRepeaterOffset, newValue) }}}
  @objc dynamic public var fmToneBurstEnabled: Bool {
    get { _fmToneBurstEnabled }
    set { if _fmToneBurstEnabled != newValue { _fmToneBurstEnabled = newValue ; sliceCmd( .fmToneBurstEnabled, newValue.as1or0) }}}
  @objc dynamic public var fmToneFreq: Float {
    get { _fmToneFreq }
    set { if _fmToneFreq != newValue { _fmToneFreq = newValue ; sliceCmd( .fmToneFreq, newValue) }}}
  @objc dynamic public var fmToneMode: String {
    get { _fmToneMode }
    set { if _fmToneMode != newValue { _fmToneMode = newValue ; sliceCmd( .fmToneMode, newValue) }}}
  @objc dynamic public var frequency: Hz {
    get { _frequency }
    set { if !_locked { if _frequency != newValue { _frequency = newValue ; sliceTuneCmd( newValue.hzToMhz) } } } }
  @objc dynamic public var locked: Bool {
    get { _locked }
    set { if _locked != newValue { _locked = newValue ; sliceLock( newValue == true ? "lock" : "unlock") }}}
  @objc dynamic public var loopAEnabled: Bool {
    get { _loopAEnabled }
    set { if _loopAEnabled != newValue { _loopAEnabled = newValue ; sliceCmd( .loopAEnabled, newValue.as1or0) }}}
  @objc dynamic public var loopBEnabled: Bool {
    get { _loopBEnabled }
    set { if _loopBEnabled != newValue { _loopBEnabled = newValue ; sliceCmd( .loopBEnabled, newValue.as1or0) }}}
  @objc dynamic public var mode: String {
    get { _mode }
    set { if _mode != newValue { _mode = newValue ; sliceCmd( .mode, newValue) }}}
  @objc dynamic public var nbEnabled: Bool {
    get { _nbEnabled }
    set { if _nbEnabled != newValue { _nbEnabled = newValue ; sliceCmd( .nbEnabled, newValue.as1or0) }}}
  @objc dynamic public var nbLevel: Int {
    get { _nbLevel }
    set { if _nbLevel != newValue {  _nbLevel = newValue ; sliceCmd( .nbLevel, newValue) }}}
  @objc dynamic public var nrEnabled: Bool {
    get { _nrEnabled }
    set { if _nrEnabled != newValue { _nrEnabled = newValue ; sliceCmd( .nrEnabled, newValue.as1or0) }}}
  @objc dynamic public var nrLevel: Int {
    get { _nrLevel }
    set { if _nrLevel != newValue {  _nrLevel = newValue ; sliceCmd( .nrLevel, newValue) }}}
  @objc dynamic public var playbackEnabled: Bool {
    get { _playbackEnabled }
    set { if _playbackEnabled != newValue { _playbackEnabled = newValue ; sliceCmd( .playbackEnabled, newValue.as1or0) }}}
  @objc dynamic public var recordEnabled: Bool {
    get { _recordEnabled }
    set { if recordEnabled != newValue { _recordEnabled = newValue ; sliceCmd( .recordEnabled, newValue.as1or0) }}}
  @objc dynamic public var repeaterOffsetDirection: String {
    get { _repeaterOffsetDirection }
    set { if _repeaterOffsetDirection != newValue { _repeaterOffsetDirection = newValue ; sliceCmd( .repeaterOffsetDirection, newValue) }}}
  @objc dynamic public var rfGain: Int {
    get { _rfGain }
    set { if _rfGain != newValue { _rfGain = newValue ; sliceCmd( .rfGain, newValue) }}}
  @objc dynamic public var ritEnabled: Bool {
    get { _ritEnabled }
    set { if _ritEnabled != newValue { _ritEnabled = newValue ; sliceCmd( .ritEnabled, newValue.as1or0) }}}
  @objc dynamic public var ritOffset: Int {
    get { _ritOffset }
    set { if _ritOffset != newValue {  _ritOffset = newValue ; sliceCmd( .ritOffset, newValue) } } }
  @objc dynamic public var rttyMark: Int {
    get { _rttyMark }
    set { if _rttyMark != newValue { _rttyMark = newValue ; sliceCmd( .rttyMark, newValue) }}}
  @objc dynamic public var rttyShift: Int {
    get { _rttyShift }
    set { if _rttyShift != newValue { _rttyShift = newValue ; sliceCmd( .rttyShift, newValue) }}}
  @objc dynamic public var rxAnt: Radio.AntennaPort {
    get { _rxAnt }
    set { if _rxAnt != newValue { _rxAnt = newValue ; sliceCmd( .rxAnt, newValue) }}}
  @objc dynamic public var step: Int {
    get { _step }
    set { if _step != newValue { _step = newValue ; sliceCmd( .step, newValue) }}}
  @objc dynamic public var stepList: String {
    get { _stepList }
    set { if _stepList != newValue { _stepList = newValue ; sliceCmd( .stepList, newValue) }}}
  @objc dynamic public var squelchEnabled: Bool {
    get { _squelchEnabled }
    set { if _squelchEnabled != newValue { _squelchEnabled = newValue ; sliceCmd( .squelchEnabled, newValue.as1or0) }}}
  @objc dynamic public var squelchLevel: Int {
    get { _squelchLevel }
    set { if _squelchLevel != newValue {  _squelchLevel = newValue ; sliceCmd( .squelchLevel, newValue) }}}
  @objc dynamic public var txAnt: String {
    get { _txAnt }
    set { if _txAnt != newValue { _txAnt = newValue ; sliceCmd( .txAnt, newValue) }}}
  @objc dynamic public var txEnabled: Bool {
    get { _txEnabled }
    set {
      if _txEnabled != newValue {
        
//        if newValue {
//          // look for the actual tx slice and disable tx there
//          if let slice = _radio.getTransmitSliceForClientId(_radio.boundClientId ?? "") {
//            // found one, disable tx
//            // due to barrier queue issue the command directly
//            // the property will be set correctly later with the status message from the radio
//            // Log.sharedInstance.logMessage
//            _log("Removed TX from Slice \(slice.sliceLetter ?? ""): id = \(slice.id)", .debug, #function, #file, #line)
//            _radio.sendCommand("slice set " + "\(slice.id) tx=0")
//          }
//        }
        
        _txEnabled = newValue
        
        _log("Enabling TX for Slice \(sliceLetter ?? ""): id = \(id)", .debug, #function, #file, #line)
        sliceCmd( .txEnabled, newValue.as1or0)
      }
    }
  }
  @objc dynamic public var txOffsetFreq: Float {
    get { _txOffsetFreq }
    set { if _txOffsetFreq != newValue { _txOffsetFreq = newValue ;sliceCmd( .txOffsetFreq, newValue) }}}
  @objc dynamic public var wnbEnabled: Bool {
    get { _wnbEnabled }
    set { if _wnbEnabled != newValue { _wnbEnabled = newValue ; sliceCmd( .wnbEnabled, newValue.as1or0) }}}
  @objc dynamic public var wnbLevel: Int {
    get { _wnbLevel }
    set { if wnbLevel != newValue {  _wnbLevel = newValue ; sliceCmd( .wnbLevel, newValue) }}}
  @objc dynamic public var xitEnabled: Bool {
    get { _xitEnabled }
    set { if _xitEnabled != newValue { _xitEnabled = newValue ; sliceCmd( .xitEnabled, newValue.as1or0) }}}
  @objc dynamic public var xitOffset: Int {
    get { _xitOffset }
    set { if _xitOffset != newValue { _xitOffset = newValue ; sliceCmd( .xitOffset, newValue) } } }

  
  @objc dynamic public var autoPan: Bool {
    get { _autoPan }
    set { if _autoPan != newValue { _autoPan = newValue }}}
  @objc dynamic public var daxClients: Int {
    get { _daxClients }
    set { if _daxClients != newValue {  _daxClients = newValue }}}
  @objc dynamic public var daxTxEnabled: Bool {
    get { _daxTxEnabled }
    set { if _daxTxEnabled != newValue { _daxTxEnabled = newValue }}}
  @objc dynamic public var detached: Bool {
    get { _detached }
    set { if _detached != newValue { _detached = newValue }}}
  @objc dynamic public var diversityChild: Bool {
    get { _diversityChild }
    set { if _diversityChild != newValue { if _diversityIsAllowed { _diversityChild = newValue } }}}
  @objc dynamic public var diversityIndex: Int {
    get { _diversityIndex }
    set { if _diversityIndex != newValue { if _diversityIsAllowed { _diversityIndex = newValue } }}}
  @objc dynamic public var diversityParent: Bool {
    get { _diversityParent }
    set { if _diversityParent != newValue { if _diversityIsAllowed { _diversityParent = newValue } }}}
  @objc dynamic public var inUse: Bool {
    return _inUse }
  
  @objc dynamic public var modeList: [String] {
    get { _modeList }
    set { if _modeList != newValue { _modeList = newValue }}}
  @objc dynamic public var nr2: Int {
    get { _nr2 }
    set { if _nr2 != newValue { _nr2 = newValue }}}
  @objc dynamic public var owner: Int {
    get { _owner }
    set { if _owner != newValue { _owner = newValue }}}
  @objc dynamic public var panadapterId: PanadapterStreamId {
    get { _panadapterId }
    set {if _panadapterId != newValue {  _panadapterId = newValue }}}
  @objc dynamic public var postDemodBypassEnabled: Bool {
    get { _postDemodBypassEnabled }
    set { if _postDemodBypassEnabled != newValue { _postDemodBypassEnabled = newValue }}}
  @objc dynamic public var postDemodHigh: Int {
    get { _postDemodHigh }
    set { if _postDemodHigh != newValue { _postDemodHigh = newValue }}}
  @objc dynamic public var postDemodLow: Int {
    get { _postDemodLow }
    set { if _postDemodLow != newValue { _postDemodLow = newValue }}}
  @objc dynamic public var qskEnabled: Bool {
    get { _qskEnabled }
    set { if _qskEnabled != newValue { _qskEnabled = newValue }}}
  @objc dynamic public var recordLength: Float {
    get { _recordLength }
    set { if _recordLength != newValue { _recordLength = newValue }}}
  @objc dynamic public var rxAntList: [Radio.AntennaPort] {
    get { _rxAntList }
    set { _rxAntList = newValue } }
  
  @objc dynamic public var clientHandle: Handle {
    return _clientHandle }
  
  @objc dynamic public var sliceLetter: String? {
    return _sliceLetter }
  
  @objc dynamic public var txAntList: [Radio.AntennaPort] {
    get { _txAntList }
    set { _txAntList = newValue } }
  
  @objc dynamic public var wide: Bool {
    get { _wide }
    set { _wide = newValue } }

  @objc dynamic public  var agcNames        = AgcMode.names()
  @objc dynamic public  let daxChoices      = Api.kDaxChannels

  public enum Offset : String {
    case up
    case down
    case simplex
  }
  public enum AgcMode : String, CaseIterable {
    case off
    case slow
    case med
    case fast
    
    static func names() -> [String] {
      return [AgcMode.off.rawValue, AgcMode.slow.rawValue, AgcMode.med.rawValue, AgcMode.fast.rawValue]
    }
  }
  public enum Mode : String, CaseIterable {
    case AM
    case SAM
    case CW
    case USB
    case LSB
    case FM
    case NFM
    case DFM
    case DIGU
    case DIGL
    case RTTY
    //    case dsb
    //    case dstr
    //    case fdv
  }

  // ----------------------------------------------------------------------------
  // MARK: - Internal properties
  
  var _active : Bool {
    get { Api.objectQ.sync { __active } }
    set { Api.objectQ.sync(flags: .barrier) {__active = newValue }}}
  var _agcMode : String {
    get { Api.objectQ.sync { __agcMode } }
    set { Api.objectQ.sync(flags: .barrier) {__agcMode = newValue }}}
  var _agcOffLevel : Int {
    get { Api.objectQ.sync { __agcOffLevel } }
    set { Api.objectQ.sync(flags: .barrier) {__agcOffLevel = newValue }}}
  var _agcThreshold : Int {
    get { Api.objectQ.sync { __agcThreshold } }
    set { Api.objectQ.sync(flags: .barrier) {__agcThreshold = newValue }}}
  var _anfEnabled : Bool {
    get { Api.objectQ.sync { __anfEnabled } }
    set { Api.objectQ.sync(flags: .barrier) {__anfEnabled = newValue }}}
  var _anfLevel : Int {
    get { Api.objectQ.sync { __anfLevel } }
    set { Api.objectQ.sync(flags: .barrier) {__anfLevel = newValue }}}
  var _apfEnabled : Bool {
    get { Api.objectQ.sync { __apfEnabled } }
    set { Api.objectQ.sync(flags: .barrier) {__apfEnabled = newValue }}}
  var _apfLevel : Int {
    get { Api.objectQ.sync { __apfLevel } }
    set { Api.objectQ.sync(flags: .barrier) {__apfLevel = newValue }}}
  var _audioGain : Int {
    get { Api.objectQ.sync { __audioGain } }
    set { Api.objectQ.sync(flags: .barrier) {__audioGain = newValue }}}
  var _audioLevel : Int {
    get { Api.objectQ.sync { __audioLevel } }
    set { Api.objectQ.sync(flags: .barrier) {__audioLevel = newValue }}}
  var _audioMute : Bool {
    get { Api.objectQ.sync { __audioMute } }
    set { Api.objectQ.sync(flags: .barrier) {__audioMute = newValue }}}
  var _audioPan : Int {
    get { Api.objectQ.sync { __audioPan } }
    set { Api.objectQ.sync(flags: .barrier) {__audioPan = newValue }}}
  var _autoPan : Bool {
    get { Api.objectQ.sync { __autoPan } }
    set { Api.objectQ.sync(flags: .barrier) {__autoPan = newValue }}}
  var _clientHandle : Handle {
    get { Api.objectQ.sync { __clientHandle } }
    set { Api.objectQ.sync(flags: .barrier) {__clientHandle = newValue }}}
  var _daxChannel : Int {
    get { Api.objectQ.sync { __daxChannel } }
    set { Api.objectQ.sync(flags: .barrier) {__daxChannel = newValue }}}
  var _daxClients : Int {
    get { Api.objectQ.sync { __daxClients } }
    set { Api.objectQ.sync(flags: .barrier) {__daxClients = newValue }}}
  var _daxTxEnabled : Bool {
    get { Api.objectQ.sync { __daxTxEnabled } }
    set { Api.objectQ.sync(flags: .barrier) {__daxTxEnabled = newValue }}}
  var _detached : Bool {
    get { Api.objectQ.sync { __detached } }
    set { Api.objectQ.sync(flags: .barrier) {__detached = newValue }}}
  var _dfmPreDeEmphasisEnabled : Bool {
    get { Api.objectQ.sync { __dfmPreDeEmphasisEnabled } }
    set { Api.objectQ.sync(flags: .barrier) {__dfmPreDeEmphasisEnabled = newValue }}}
  var _digitalLowerOffset : Int {
    get { Api.objectQ.sync { __digitalLowerOffset } }
    set { Api.objectQ.sync(flags: .barrier) {__digitalLowerOffset = newValue }}}
  var _digitalUpperOffset : Int {
    get { Api.objectQ.sync { __digitalUpperOffset } }
    set { Api.objectQ.sync(flags: .barrier) {__digitalUpperOffset = newValue }}}
  var _diversityChild : Bool {
    get { Api.objectQ.sync { __diversityChild } }
    set { Api.objectQ.sync(flags: .barrier) {__diversityChild = newValue }}}
  var _diversityEnabled : Bool {
    get { Api.objectQ.sync { __diversityEnabled } }
    set { Api.objectQ.sync(flags: .barrier) {__diversityEnabled = newValue }}}
  var _diversityIndex : Int {
    get { Api.objectQ.sync { __diversityIndex } }
    set { Api.objectQ.sync(flags: .barrier) {__diversityIndex = newValue }}}
  var _diversityParent : Bool {
    get { Api.objectQ.sync { __diversityParent } }
    set { Api.objectQ.sync(flags: .barrier) {__diversityParent = newValue }}}
  var _filterHigh : Int {
    get { Api.objectQ.sync { __filterHigh } }
    set { Api.objectQ.sync(flags: .barrier) {__filterHigh = newValue }}}
  var _filterLow : Int {
    get { Api.objectQ.sync { __filterLow } }
    set { Api.objectQ.sync(flags: .barrier) {__filterLow = newValue }}}
  var _fmDeviation : Int {
    get { Api.objectQ.sync { __fmDeviation } }
    set { Api.objectQ.sync(flags: .barrier) {__fmDeviation = newValue }}}
  var _fmRepeaterOffset : Float {
    get { Api.objectQ.sync { __fmRepeaterOffset } }
    set { Api.objectQ.sync(flags: .barrier) {__fmRepeaterOffset = newValue }}}
  var _fmToneBurstEnabled : Bool {
    get { Api.objectQ.sync { __fmToneBurstEnabled } }
    set { Api.objectQ.sync(flags: .barrier) {__fmToneBurstEnabled = newValue }}}
  var _fmToneFreq : Float {
    get { Api.objectQ.sync { __fmToneFreq } }
    set { Api.objectQ.sync(flags: .barrier) {__fmToneFreq = newValue }}}
  var _fmToneMode : String {
    get { Api.objectQ.sync { __fmToneMode } }
    set { Api.objectQ.sync(flags: .barrier) {__fmToneMode = newValue }}}
  var _frequency : Hz {
    get { Api.objectQ.sync { __frequency } }
    set { Api.objectQ.sync(flags: .barrier) {__frequency = newValue }}}
  var _inUse : Bool {
    get { Api.objectQ.sync { __inUse } }
    set { Api.objectQ.sync(flags: .barrier) {__inUse = newValue }}}
  var _locked : Bool {
    get { Api.objectQ.sync { __locked } }
    set { Api.objectQ.sync(flags: .barrier) {__locked = newValue }}}
  var _loopAEnabled : Bool {
    get { Api.objectQ.sync { __loopAEnabled } }
    set { Api.objectQ.sync(flags: .barrier) {__loopAEnabled = newValue }}}
  var _loopBEnabled : Bool {
    get { Api.objectQ.sync { __loopBEnabled } }
    set { Api.objectQ.sync(flags: .barrier) {__loopBEnabled = newValue }}}
  var _mode : String {
    get { Api.objectQ.sync { __mode } }
    set { Api.objectQ.sync(flags: .barrier) {__mode = newValue }}}
  var _modeList : [String] {
    get { Api.objectQ.sync { __modeList } }
    set { Api.objectQ.sync(flags: .barrier) {__modeList = newValue }}}
  var _nbEnabled : Bool {
    get { Api.objectQ.sync { __nbEnabled } }
    set { Api.objectQ.sync(flags: .barrier) {__nbEnabled = newValue }}}
  var _nbLevel : Int {
    get { Api.objectQ.sync { __nbLevel } }
    set { Api.objectQ.sync(flags: .barrier) {__nbLevel = newValue }}}
  var _nrEnabled : Bool {
    get { Api.objectQ.sync { __nrEnabled } }
    set { Api.objectQ.sync(flags: .barrier) {__nrEnabled = newValue }}}
  var _nrLevel : Int {
    get { Api.objectQ.sync { __nrLevel } }
    set { Api.objectQ.sync(flags: .barrier) {__nrLevel = newValue }}}
  var _nr2 : Int {
    get { Api.objectQ.sync { __nr2 } }
    set { Api.objectQ.sync(flags: .barrier) {__nr2 = newValue }}}
  var _owner : Int {
    get { Api.objectQ.sync { __owner } }
    set { Api.objectQ.sync(flags: .barrier) {__owner = newValue }}}
  var _panadapterId     : PanadapterStreamId  {
    get { Api.objectQ.sync { __panadapterId } }
    set { Api.objectQ.sync(flags: .barrier) {__panadapterId = newValue }}}
  var _playbackEnabled : Bool {
    get { Api.objectQ.sync { __playbackEnabled } }
    set { Api.objectQ.sync(flags: .barrier) {__playbackEnabled = newValue }}}
  var _postDemodBypassEnabled : Bool {
    get { Api.objectQ.sync { __postDemodBypassEnabled } }
    set { Api.objectQ.sync(flags: .barrier) {__postDemodBypassEnabled = newValue }}}
  var _postDemodHigh : Int {
    get { Api.objectQ.sync { __postDemodHigh } }
    set { Api.objectQ.sync(flags: .barrier) {__postDemodHigh = newValue }}}
  var _postDemodLow : Int {
    get { Api.objectQ.sync { __postDemodLow } }
    set { Api.objectQ.sync(flags: .barrier) {__postDemodLow = newValue }}}
  var _qskEnabled : Bool {
    get { Api.objectQ.sync { __qskEnabled } }
    set { Api.objectQ.sync(flags: .barrier) {__qskEnabled = newValue }}}
  var _recordEnabled : Bool {
    get { Api.objectQ.sync { __recordEnabled } }
    set { Api.objectQ.sync(flags: .barrier) {__recordEnabled = newValue }}}
  var _recordLength : Float {
    get { Api.objectQ.sync { __recordLength } }
    set { Api.objectQ.sync(flags: .barrier) {__recordLength = newValue }}}
  var _repeaterOffsetDirection : String {
    get { Api.objectQ.sync { __repeaterOffsetDirection } }
    set { Api.objectQ.sync(flags: .barrier) {__repeaterOffsetDirection = newValue }}}
  var _rfGain : Int {
    get { Api.objectQ.sync { __rfGain } }
    set { Api.objectQ.sync(flags: .barrier) {__rfGain = newValue }}}
  var _ritEnabled : Bool {
    get { Api.objectQ.sync { __ritEnabled } }
    set { Api.objectQ.sync(flags: .barrier) {__ritEnabled = newValue }}}
  var _ritOffset : Int {
    get { Api.objectQ.sync { __ritOffset } }
    set { Api.objectQ.sync(flags: .barrier) {__ritOffset = newValue }}}
  var _rttyMark : Int {
    get { Api.objectQ.sync { __rttyMark } }
    set { Api.objectQ.sync(flags: .barrier) {__rttyMark = newValue }}}
  var _rttyShift : Int {
    get { Api.objectQ.sync { __rttyShift } }
    set { Api.objectQ.sync(flags: .barrier) {__rttyShift = newValue }}}
  var _rxAnt : String {
    get { Api.objectQ.sync { __rxAnt } }
    set { Api.objectQ.sync(flags: .barrier) {__rxAnt = newValue }}}
  var _rxAntList : [String] {
    get { Api.objectQ.sync { __rxAntList } }
    set { Api.objectQ.sync(flags: .barrier) {__rxAntList = newValue }}}
  var _sliceLetter : String? {
    get { Api.objectQ.sync { __sliceLetter } }
    set { Api.objectQ.sync(flags: .barrier) {__sliceLetter = newValue }}}
  var _step : Int {
    get { Api.objectQ.sync { __step } }
    set { Api.objectQ.sync(flags: .barrier) {__step = newValue }}}
  var _squelchEnabled : Bool {
    get { Api.objectQ.sync { __squelchEnabled } }
    set { Api.objectQ.sync(flags: .barrier) {__squelchEnabled = newValue }}}
  var _squelchLevel : Int {
    get { Api.objectQ.sync { __squelchLevel } }
    set { Api.objectQ.sync(flags: .barrier) {__squelchLevel = newValue }}}
  var _stepList : String {
    get { Api.objectQ.sync { __stepList } }
    set { Api.objectQ.sync(flags: .barrier) {__stepList = newValue }}}
  var _txAnt : String {
    get { Api.objectQ.sync { __txAnt } }
    set { Api.objectQ.sync(flags: .barrier) {__txAnt = newValue }}}
  var _txAntList : [String] {
    get { Api.objectQ.sync { __txAntList } }
    set { Api.objectQ.sync(flags: .barrier) {__txAntList = newValue }}}
  var _txEnabled : Bool {
    get { Api.objectQ.sync { __txEnabled } }
    set { Api.objectQ.sync(flags: .barrier) {__txEnabled = newValue }}}
  var _txOffsetFreq : Float {
    get { Api.objectQ.sync { __txOffsetFreq } }
    set { Api.objectQ.sync(flags: .barrier) {__txOffsetFreq = newValue }}}
  var _wide : Bool {
    get { Api.objectQ.sync { __wide } }
    set { Api.objectQ.sync(flags: .barrier) {__wide = newValue }}}
  var _wnbEnabled : Bool {
    get { Api.objectQ.sync { __wnbEnabled } }
    set { Api.objectQ.sync(flags: .barrier) {__wnbEnabled = newValue }}}
  var _wnbLevel : Int {
    get { Api.objectQ.sync { __wnbLevel } }
    set { Api.objectQ.sync(flags: .barrier) {__wnbLevel = newValue }}}
  var _xitEnabled : Bool {
    get { Api.objectQ.sync { __xitEnabled } }
    set { Api.objectQ.sync(flags: .barrier) {__xitEnabled = newValue }}}
  var _xitOffset : Int {
    get { Api.objectQ.sync { __xitOffset } }
    set { Api.objectQ.sync(flags: .barrier) {__xitOffset = newValue }}}

  enum Token : String {
    case active
    case agcMode                    = "agc_mode"
    case agcOffLevel                = "agc_off_level"
    case agcThreshold               = "agc_threshold"
    case anfEnabled                 = "anf"
    case anfLevel                   = "anf_level"
    case apfEnabled                 = "apf"
    case apfLevel                   = "apf_level"
    case audioGain                  = "audio_gain"
    case audioLevel                 = "audio_level"
    case audioMute                  = "audio_mute"
    case audioPan                   = "audio_pan"
    case clientHandle               = "client_handle"
    case daxChannel                 = "dax"
    case daxClients                 = "dax_clients"
    case daxTxEnabled               = "dax_tx"
    case detached
    case dfmPreDeEmphasisEnabled    = "dfm_pre_de_emphasis"
    case digitalLowerOffset         = "digl_offset"
    case digitalUpperOffset         = "digu_offset"
    case diversityEnabled           = "diversity"
    case diversityChild             = "diversity_child"
    case diversityIndex             = "diversity_index"
    case diversityParent            = "diversity_parent"
    case filterHigh                 = "filter_hi"
    case filterLow                  = "filter_lo"
    case fmDeviation                = "fm_deviation"
    case fmRepeaterOffset           = "fm_repeater_offset_freq"
    case fmToneBurstEnabled         = "fm_tone_burst"
    case fmToneMode                 = "fm_tone_mode"
    case fmToneFreq                 = "fm_tone_value"
    case frequency                  = "rf_frequency"
    case ghost
    case inUse                      = "in_use"
    case locked                     = "lock"
    case loopAEnabled               = "loopa"
    case loopBEnabled               = "loopb"
    case mode
    case modeList                   = "mode_list"
    case nbEnabled                  = "nb"
    case nbLevel                    = "nb_level"
    case nrEnabled                  = "nr"
    case nrLevel                    = "nr_level"
    case nr2
    case owner
    case panadapterId               = "pan"
    case playbackEnabled            = "play"
    case postDemodBypassEnabled     = "post_demod_bypass"
    case postDemodHigh              = "post_demod_high"
    case postDemodLow               = "post_demod_low"
    case qskEnabled                 = "qsk"
    case recordEnabled              = "record"
    case recordTime                 = "record_time"
    case repeaterOffsetDirection    = "repeater_offset_dir"
    case rfGain                     = "rfgain"
    case ritEnabled                 = "rit_on"
    case ritOffset                  = "rit_freq"
    case rttyMark                   = "rtty_mark"
    case rttyShift                  = "rtty_shift"
    case rxAnt                      = "rxant"
    case rxAntList                  = "ant_list"
    case sliceLetter                = "index_letter"
    case squelchEnabled             = "squelch"
    case squelchLevel               = "squelch_level"
    case step
    case stepList                   = "step_list"
    case txEnabled                  = "tx"
    case txAnt                      = "txant"
    case txAntList                  = "tx_ant_list"
    case txOffsetFreq               = "tx_offset_freq"
    case wide
    case wnbEnabled                 = "wnb"
    case wnbLevel                   = "wnb_level"
    case xitEnabled                 = "xit_on"
    case xitOffset                  = "xit_freq"
  }

  // ----------------------------------------------------------------------------
  // MARK: - Private properties
  
  private var _diversityIsAllowed   : Bool { return _radio.radioModel == "FLEX-6700" || _radio.radioModel == "FLEX-6700R" }
  private var _initialized          = false
  private let _log                  = Log.sharedInstance.logMessage
  private let _radio                : Radio

  private let kTuneStepList         = [1, 10, 50, 100, 500, 1_000, 2_000, 3_000]
  
  // ------------------------------------------------------------------------------
  // MARK: - Class methods
  
  /// Parse a Slice status message
  ///   Format: <sliceId> <key=value> <key=value> ...<key=value>
  ///
  ///   StatusParser Protocol method, executes on the parseQ
  ///
  /// - Parameters:
  ///   - keyValues:      a KeyValuesArray
  ///   - radio:          the current Radio class
  ///   - queue:          a parse Queue for the object
  ///   - inUse:          false = "to be deleted"
  ///
  class func parseStatus(_ radio: Radio, _ properties: KeyValuesArray, _ inUse: Bool = true) {
    
    // get the Id
    if let id = properties[0].key.objectId {
      
      // is the object in use?
      if inUse {
        
        // YES, does it exist?
        if radio.slices[id] == nil {
          
         // create a new Slice & add it to the Slices collection
          radio.slices[id] = xLib6000.Slice(radio: radio, id: id)
          
          //        // scan the meters
          //        for (_, meter) in radio.meters {
          //
          //          // is this meter associated with this slice?
          //          if meter.source == Meter.Source.slice.rawValue && meter.number == sliceId {
          //
          //            // YES, add it to this Slice
          //            radio.slices[sliceId]!.addMeter(meter)
          //          }
          //        }
        }
        // pass the remaining key values to the Slice for parsing
        radio.slices[id]!.parseProperties(radio, Array(properties.dropFirst(1)) )
        
      } else {
        
        // does it exist?
        if radio.slices[id] != nil {
          
          // YES, remove it, notify observers
          NC.post(.sliceWillBeRemoved, object: radio.slices[id] as Any?)

          radio.slices[id] = nil
          
          Log.sharedInstance.logMessage("Slice removed: id = \(id)", .debug, #function, #file, #line)

          NC.post(.sliceHasBeenRemoved, object: id as Any?)
        }
      }
    }
  }

  // ----------------------------------------------------------------------------
  // MARK: - Initialization
  
  /// Initialize a Slice
  ///
  /// - Parameters:
  ///   - radio:        the Radio instance
  ///   - id:           a Slice Id
  ///
  public init(radio: Radio, id: SliceId) {

    _radio = radio
    self.id = id
    super.init()
    
    // setup the Step List
    var stepListString = kTuneStepList.reduce("") {start , value in "\(start), \(String(describing: value))" }
    stepListString = String(stepListString.dropLast())
    _stepList = stepListString
    
    // set filterLow & filterHigh to default values
    setupDefaultFilters(_mode)
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Instance methods
  
  /// Set the default Filter widths
  ///
  /// - Parameters:
  ///   - mode:       demod mode
  ///
  func setupDefaultFilters(_ mode: String) {
    
    if let modeValue = Mode(rawValue: mode) {
      
      switch modeValue {
        
      case .CW:
        _filterLow = 450
        _filterHigh = 750
        
      case .RTTY:
        _filterLow = -285
        _filterHigh = 115
        
      case .AM, .SAM:
        _filterLow = -3_000
        _filterHigh = 3_000
        
      case .FM, .NFM, .DFM:
        _filterLow = -8_000
        _filterHigh = 8_000
        
      case .LSB, .DIGL:
        _filterLow = -2_400
        _filterHigh = -300
        
      case .USB, .DIGU:
        _filterLow = 300
        _filterHigh = 2_400
      }
    }
  }
  /// Restrict the Filter High value
  ///
  /// - Parameters:
  ///   - value:          the value
  /// - Returns:          adjusted value
  ///
  func filterHighLimits(_ value: Int) -> Int {
    
    var newValue = (value < filterLow + 10 ? filterLow + 10 : value)
    
    if let modeType = Mode(rawValue: mode.lowercased()) {
      switch modeType {
        
      case .FM, .NFM:
        _log("Cannot change Filter width in FM mode", .info, #function, #file, #line)
        newValue = value
        
      case .CW:
        newValue = (newValue > 12_000 - _radio.transmit.cwPitch ? 12_000 - _radio.transmit.cwPitch : newValue)
        
      case .RTTY:
        newValue = (newValue > rttyMark ? rttyMark : newValue)
        newValue = (newValue < 50 ? 50 : newValue)
        
      case .AM, .SAM, .DFM:
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
    
    if let modeType = Mode(rawValue: mode.lowercased()) {
      switch modeType {
        
      case .FM, .NFM:
        _log("Cannot change Filter width in FM mode", .info, #function, #file, #line)
        newValue = value
        
      case .CW:
        newValue = (newValue < -12_000 - _radio.transmit.cwPitch ? -12_000 - _radio.transmit.cwPitch : newValue)
        
      case .RTTY:
        newValue = (newValue < -12_000 + rttyMark ? -12_000 + rttyMark : newValue)
        newValue = (newValue > -(50 + rttyShift) ? -(50 + rttyShift) : newValue)
        
      case .AM, .SAM, .DFM:
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
  /// Parse Slice key/value pairs
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
        _log("Unknown Slice token: \(property.key) = \(property.value)", .warning, #function, #file, #line)
        continue
      }
      // Known keys, in alphabetical order
      switch token {
        
      case .active:                   willChangeValue(for: \.active)                  ; _active = property.value.bValue                   ; didChangeValue(for: \.active)
      case .agcMode:                  willChangeValue(for: \.agcMode)                 ; _agcMode = property.value                         ; didChangeValue(for: \.agcMode)
      case .agcOffLevel:              willChangeValue(for: \.agcOffLevel)             ; _agcOffLevel = property.value.iValue              ; didChangeValue(for: \.agcOffLevel)
      case .agcThreshold:             willChangeValue(for: \.agcThreshold)            ; _agcThreshold = property.value.iValue             ; didChangeValue(for: \.agcThreshold)
      case .anfEnabled:               willChangeValue(for: \.anfEnabled)              ; _anfEnabled = property.value.bValue               ; didChangeValue(for: \.anfEnabled)
      case .anfLevel:                 willChangeValue(for: \.anfLevel)                ; _anfLevel = property.value.iValue                 ; didChangeValue(for: \.anfLevel)
      case .apfEnabled:               willChangeValue(for: \.apfEnabled)              ; _apfEnabled = property.value.bValue               ; didChangeValue(for: \.apfEnabled)
      case .apfLevel:                 willChangeValue(for: \.apfLevel)                ; _apfLevel = property.value.iValue                 ; didChangeValue(for: \.apfLevel)
      case .audioGain:                willChangeValue(for: \.audioGain)               ; _audioGain = property.value.iValue                ; didChangeValue(for: \.audioGain)
      case .audioLevel:               willChangeValue(for: \.audioLevel)              ; _audioLevel = property.value.iValue               ; didChangeValue(for: \.audioLevel)
      case .audioMute:                willChangeValue(for: \.audioMute)               ; _audioMute = property.value.bValue                ; didChangeValue(for: \.audioMute)
      case .audioPan:                 willChangeValue(for: \.audioPan)                ; _audioPan = property.value.iValue                 ; didChangeValue(for: \.audioPan)
      case .clientHandle:             willChangeValue(for: \.clientHandle)            ; _clientHandle = property.value.handle ?? 0        ; didChangeValue(for: \.clientHandle)
      case .daxChannel:
        if _daxChannel != 0 && property.value.iValue == 0 {
          // remove this slice from the AudioStream it was using
          if let audioStream = radio.findAudioStream(with: _daxChannel) { audioStream.slice = nil }
        }
        willChangeValue(for: \.daxChannel) ; _daxChannel = property.value.iValue ; didChangeValue(for: \.daxChannel)
      case .daxTxEnabled:             willChangeValue(for: \.daxTxEnabled)            ; _daxTxEnabled = property.value.bValue             ; didChangeValue(for: \.daxTxEnabled)
      case .detached:                 willChangeValue(for: \.detached)                ; _detached = property.value.bValue                 ; didChangeValue(for: \.detached)
      case .dfmPreDeEmphasisEnabled:  willChangeValue(for: \.dfmPreDeEmphasisEnabled) ; _dfmPreDeEmphasisEnabled = property.value.bValue  ; didChangeValue(for: \.dfmPreDeEmphasisEnabled)
      case .digitalLowerOffset:       willChangeValue(for: \.digitalLowerOffset)      ; _digitalLowerOffset = property.value.iValue       ; didChangeValue(for: \.digitalLowerOffset)
      case .digitalUpperOffset:       willChangeValue(for: \.digitalUpperOffset)      ; _digitalUpperOffset = property.value.iValue       ; didChangeValue(for: \.digitalUpperOffset)
      case .diversityEnabled:         willChangeValue(for: \.diversityEnabled)        ; _diversityEnabled = property.value.bValue         ; didChangeValue(for: \.diversityEnabled)
      case .diversityChild:           willChangeValue(for: \.diversityChild)          ; _diversityChild = property.value.bValue           ; didChangeValue(for: \.diversityChild)
      case .diversityIndex:           willChangeValue(for: \.diversityIndex)          ; _diversityIndex = property.value.iValue           ; didChangeValue(for: \.diversityIndex)
        
      case .filterHigh:               willChangeValue(for: \.filterHigh)              ; _filterHigh = property.value.iValue               ; didChangeValue(for: \.filterHigh)
      case .filterLow:                willChangeValue(for: \.filterLow)               ; _filterLow = property.value.iValue                ; didChangeValue(for: \.filterLow)
      case .fmDeviation:              willChangeValue(for: \.fmDeviation)             ; _fmDeviation = property.value.iValue              ; didChangeValue(for: \.fmDeviation)
      case .fmRepeaterOffset:         willChangeValue(for: \.fmRepeaterOffset)        ; _fmRepeaterOffset = property.value.fValue         ; didChangeValue(for: \.fmRepeaterOffset)
      case .fmToneBurstEnabled:       willChangeValue(for: \.fmToneBurstEnabled)      ; _fmToneBurstEnabled = property.value.bValue       ; didChangeValue(for: \.fmToneBurstEnabled)
      case .fmToneMode:               willChangeValue(for: \.fmToneMode)              ; _fmToneMode = property.value                      ; didChangeValue(for: \.fmToneMode)
      case .fmToneFreq:               willChangeValue(for: \.fmToneFreq)              ; _fmToneFreq = property.value.fValue               ; didChangeValue(for: \.fmToneFreq)
      case .frequency:                willChangeValue(for: \.frequency)               ; _frequency = property.value.mhzToHz               ; didChangeValue(for: \.frequency)
      case .ghost:                    _log("Unprocessed Slice property: \( property.key).\(property.value)", .warning, #function, #file, #line)
      case .inUse:                    willChangeValue(for: \.inUse)                   ; _inUse = property.value.bValue                    ; didChangeValue(for: \.inUse)
      case .locked:                   willChangeValue(for: \.locked)                  ; _locked = property.value.bValue                   ; didChangeValue(for: \.locked)
      case .loopAEnabled:             willChangeValue(for: \.loopAEnabled)            ; _loopAEnabled = property.value.bValue             ; didChangeValue(for: \.loopAEnabled)
      case .loopBEnabled:             willChangeValue(for: \.loopBEnabled)            ; _loopBEnabled = property.value.bValue             ; didChangeValue(for: \.loopBEnabled)
      case .mode:                     willChangeValue(for: \.mode)                    ; _mode = property.value.uppercased()               ; didChangeValue(for: \.mode)
      case .modeList:                 willChangeValue(for: \.modeList)                ; _modeList = property.value.list                   ; didChangeValue(for: \.modeList)
      case .nbEnabled:                willChangeValue(for: \.nbEnabled)               ; _nbEnabled = property.value.bValue                ; didChangeValue(for: \.nbEnabled)
      case .nbLevel:                  willChangeValue(for: \.nbLevel)                 ; _nbLevel = property.value.iValue                  ; didChangeValue(for: \.nbLevel)
      case .nrEnabled:                willChangeValue(for: \.nrEnabled)               ; _nrEnabled = property.value.bValue                ; didChangeValue(for: \.nrEnabled)
      case .nrLevel:                  willChangeValue(for: \.nrLevel)                 ; _nrLevel = property.value.iValue                  ; didChangeValue(for: \.nrLevel)
      case .nr2:                      willChangeValue(for: \.nr2)                     ; _nr2 = property.value.iValue                      ; didChangeValue(for: \.nr2)
      case .owner:                    willChangeValue(for: \.owner)                   ; _nr2 = property.value.iValue                      ; didChangeValue(for: \.owner)
      case .panadapterId:             willChangeValue(for: \.panadapterId)            ; _panadapterId = property.value.streamId ?? 0      ; didChangeValue(for: \.panadapterId)
      case .playbackEnabled:          willChangeValue(for: \.playbackEnabled)         ; _playbackEnabled = (property.value == "enabled") || (property.value == "1")  ; didChangeValue(for: \.playbackEnabled)
      case .postDemodBypassEnabled:   willChangeValue(for: \.postDemodBypassEnabled)  ; _postDemodBypassEnabled = property.value.bValue   ; didChangeValue(for: \.postDemodBypassEnabled)
      case .postDemodLow:             willChangeValue(for: \.postDemodLow)            ; _postDemodLow = property.value.iValue             ; didChangeValue(for: \.postDemodLow)
      case .postDemodHigh:            willChangeValue(for: \.postDemodHigh)           ; _postDemodHigh = property.value.iValue            ; didChangeValue(for: \.postDemodHigh)
      case .qskEnabled:               willChangeValue(for: \.qskEnabled)              ; _qskEnabled = property.value.bValue               ; didChangeValue(for: \.qskEnabled)
      case .recordEnabled:            willChangeValue(for: \.recordEnabled)           ; _recordEnabled = property.value.bValue            ; didChangeValue(for: \.recordEnabled)
      case .repeaterOffsetDirection:  willChangeValue(for: \.repeaterOffsetDirection) ; _repeaterOffsetDirection = property.value         ; didChangeValue(for: \.repeaterOffsetDirection)
      case .rfGain:                   willChangeValue(for: \.rfGain)                  ; _rfGain = property.value.iValue                   ; didChangeValue(for: \.rfGain)
      case .ritOffset:                willChangeValue(for: \.ritOffset)               ; _ritOffset = property.value.iValue                ; didChangeValue(for: \.ritOffset)
      case .ritEnabled:               willChangeValue(for: \.ritEnabled)              ; _ritEnabled = property.value.bValue               ; didChangeValue(for: \.ritEnabled)
      case .rttyMark:                 willChangeValue(for: \.rttyMark)                ; _rttyMark = property.value.iValue                 ; didChangeValue(for: \.rttyMark)
      case .rttyShift:                willChangeValue(for: \.rttyShift)               ; _rttyShift = property.value.iValue                ; didChangeValue(for: \.rttyShift)
      case .rxAnt:                    willChangeValue(for: \.rxAnt)                   ; _rxAnt = property.value                           ; didChangeValue(for: \.rxAnt)
      case .rxAntList:                willChangeValue(for: \.rxAntList)               ; _rxAntList = property.value.list                  ; didChangeValue(for: \.rxAntList)
      case .sliceLetter:              willChangeValue(for: \.sliceLetter)             ; _sliceLetter = property.value                     ; didChangeValue(for: \.sliceLetter)
      case .squelchEnabled:           willChangeValue(for: \.squelchEnabled)          ; _squelchEnabled = property.value.bValue           ; didChangeValue(for: \.squelchEnabled)
      case .squelchLevel:             willChangeValue(for: \.squelchLevel)            ; _squelchLevel = property.value.iValue             ; didChangeValue(for: \.squelchLevel)
      case .step:                     willChangeValue(for: \.step)                    ; _step = property.value.iValue                     ; didChangeValue(for: \.step)
      case .stepList:                 willChangeValue(for: \.stepList)                ; _stepList = property.value                        ; didChangeValue(for: \.stepList)
      case .txEnabled:                willChangeValue(for: \.txEnabled)               ; _txEnabled = property.value.bValue                ; didChangeValue(for: \.txEnabled)
      case .txAnt:                    willChangeValue(for: \.txAnt)                   ; _txAnt = property.value                           ; didChangeValue(for: \.txAnt)
      case .txAntList:                willChangeValue(for: \.txAntList)               ; _txAntList = property.value.list                  ; didChangeValue(for: \.txAntList)
      case .txOffsetFreq:             willChangeValue(for: \.txOffsetFreq)            ; _txOffsetFreq = property.value.fValue             ; didChangeValue(for: \.txOffsetFreq)
      case .wide:                     willChangeValue(for: \.wide)                    ; _wide = property.value.bValue                     ; didChangeValue(for: \.wide)
      case .wnbEnabled:               willChangeValue(for: \.wnbEnabled)              ; _wnbEnabled = property.value.bValue               ; didChangeValue(for: \.wnbEnabled)
      case .wnbLevel:                 willChangeValue(for: \.wnbLevel)                ; _wnbLevel = property.value.iValue                 ; didChangeValue(for: \.wnbLevel)
      case .xitOffset:                willChangeValue(for: \.xitOffset)               ; _xitOffset = property.value.iValue                ; didChangeValue(for: \.xitOffset)
      case .xitEnabled:               willChangeValue(for: \.xitEnabled)              ; _xitEnabled = property.value.bValue               ; didChangeValue(for: \.xitEnabled)
      case .daxClients, .diversityParent, .recordTime: break // ignored
      }
    }
    if _initialized == false && inUse == true && panadapterId != 0 && frequency != 0 && mode != "" {
      
      // mark it as initialized
      _initialized = true
      
      _log("Slice added: id = \(id)", .debug, #function, #file, #line)

      // notify all observers
      NC.post(.sliceHasBeenAdded, object: self)
    }
  }
  /// Remove this Slice
  ///
  public func remove() {
    // tell the Radio to remove this Slice
    _radio.sendCommand("slice remove \(id)")
    
    // notify all observers
    NC.post(.sliceWillBeRemoved, object: self as Any?)
  }
  /// Requent the Slice frequency error values
  ///
  /// - Parameters:
  ///   - id:                 Slice Id
  ///   - callback:           ReplyHandler (optional)
  ///
  public func errorRequest(_ id: SliceId, callback: ReplyHandler? = nil) {
    
    // ask the Radio for the current frequency error
    _radio.sendCommand("slice " + "get_error" + " \(id)", replyTo: callback == nil ? Api.sharedInstance.radio!.defaultReplyHandler : callback)
  }
  /// Request a list of slice Stream Id's
  ///
  /// - Parameter callback:   ReplyHandler (optional)
  ///
  public func listRequest(callback: ReplyHandler? = nil) {
    
    // ask the Radio for a list of Slices
    _radio.sendCommand("slice " + "list", replyTo: callback == nil ? Api.sharedInstance.radio!.defaultReplyHandler : callback)
  }
  public func setRecord(_ value: Bool) {
    
    _radio.sendCommand("slice set " + "\(id) record=\(value.as1or0)")
  }
  
  public func setPlay(_ value: Bool) {
    
    _radio.sendCommand("slice set " + "\(id) play=\(value.as1or0)")
  }
  /// Set a Slice tune property on the Radio
  ///
  /// - Parameters:
  ///   - value:      the new value
  ///
  public func sliceTuneCmd(_ value: Any) {
    
    _radio.sendCommand("slice tune " + "\(id) \(value) autopan=\(_autoPan.as1or0)")
  }
  /// Set a Slice Lock property on the Radio
  ///
  /// - Parameters:
  ///   - value:      the new value (lock / unlock)
  ///
  public func sliceLock(_ value: String) {
    
    _radio.sendCommand("slice " + value + " \(id)")
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Private methods
  
  /// Set a Slice property on the Radio
  ///
  /// - Parameters:
  ///   - token:      the parse token
  ///   - value:      the new value
  ///
  private func sliceCmd(_ token: Token, _ value: Any) {
    
    _radio.sendCommand("slice set " + "\(id) " + token.rawValue + "=\(value)")
  }
  /// Set an Audio property on the Radio
  ///
  /// - Parameters:
  ///   - token:      the parse token
  ///   - value:      the new value
  ///
  private func audioCmd(_ token: Token, value: Any) {
    _radio.sendCommand("audio client 0 slice " + "\(id) " + token.rawValue + " \(value)")
  }
  /// Set an Audio property on the Radio
  ///
  /// - Parameters:
  ///   - token:      a String
  ///   - value:      the new value
  ///
  private func audioCmd(_ token: String, value: Any) {
    // NOTE: commands use this format when the Token received does not match the Token sent
    //      e.g. see EqualizerCommands.swift where "63hz" is received vs "63Hz" must be sent
    _radio.sendCommand("audio client 0 slice " + "\(id) " + token + " \(value)")
  }
  /// Set a Filter property on the Radio
  ///
  /// - Parameters:
  ///   - value:      the new value
  ///
  private func filterCmd(low: Any, high: Any) {
    
    _radio.sendCommand("filt " + "\(id)" + " \(low)" + " \(high)")
  }
  
  // ----------------------------------------------------------------------------
  // *** Hidden properties (Do NOT use) ***
  
  private var __active                  = false
  private var __agcMode                 = AgcMode.off.rawValue
  private var __agcOffLevel             = 0
  private var __agcThreshold            = 0
  private var __anfEnabled              = false
  private var __anfLevel                = 0
  private var __apfEnabled              = false
  private var __apfLevel                = 0
  private var __audioGain               = 0
  private var __audioLevel              = 0
  private var __audioMute               = false
  private var __audioPan                = 0
  private var __autoPan                 = false
  private var __clientHandle            : Handle = 0
  private var __daxChannel              = 0
  private var __daxClients              = 0
  private var __daxTxEnabled            = false
  private var __detached                = false
  private var __dfmPreDeEmphasisEnabled = false
  private var __digitalLowerOffset      = 0
  private var __digitalUpperOffset      = 0
  private var __diversityChild          = false
  private var __diversityEnabled        = false
  private var __diversityIndex          = 0
  private var __diversityParent         = false
  private var __filterHigh              = 0
  private var __filterLow               = 0
  private var __fmDeviation             = 0
  private var __fmRepeaterOffset        : Float = 0.0
  private var __fmToneBurstEnabled      = false
  private var __fmToneFreq              : Float = 0.0
  private var __fmToneMode              = ""
  private var __frequency               : Hz = 0
  private var __inUse                   = false
  private var __locked                  = false
  private var __loopAEnabled            = false
  private var __loopBEnabled            = false
  private var __mode                    = Mode.LSB.rawValue
  private var __modeList                = [String]()
  private var __nbEnabled               = false
  private var __nbLevel                 = 0
  private var __nrEnabled               = false
  private var __nrLevel                 = 0
  private var __nr2                     = 0
  private var __owner                   = 0
  private var __panadapterId            : PanadapterStreamId = 0
  private var __playbackEnabled         = false
  private var __postDemodBypassEnabled  = false
  private var __postDemodHigh           = 0
  private var __postDemodLow            = 0
  private var __qskEnabled              = false
  private var __recordEnabled           = false
  private var __recordLength            : Float = 0.0
  private var __repeaterOffsetDirection = Offset.simplex.rawValue
  private var __rfGain                  = 0
  private var __ritEnabled              = false
  private var __ritOffset               = 0
  private var __rttyMark                = 0
  private var __rttyShift               = 0
  private var __rxAnt                   = ""
  private var __rxAntList               = [String]()
  private var __sliceLetter             : String?
  private var __step                    = 0
  private var __squelchEnabled          = false
  private var __squelchLevel            = 0
  private var __stepList                = ""
  private var __txAnt                   = ""
  private var __txAntList               = [String]()
  private var __txEnabled               = false
  private var __txOffsetFreq            : Float = 0.0
  private var __wide                    = false
  private var __wnbEnabled              = false
  private var __wnbLevel                = 0
  private var __xitEnabled              = false
  private var __xitOffset               = 0
}
