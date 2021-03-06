//
//  OldApiTests.swift
//  xLib6000Tests
//
//  Created by Douglas Adams on 2/15/20.
//

import XCTest
@testable import xLib6000

class OldApiTests: XCTestCase {
  let connectAsGui = true
  let requiredVersion = "v1 || v2 OldApi"
  let showInfoMessages = false

  // Helper functions
  func discoverRadio(logState: Api.NSLogging = .normal) -> Radio? {
    let discovery = Discovery.sharedInstance
    sleep(2)
    if discovery.discoveredRadios.count > 0 {
      
      Swift.print("***** Radio found (v\(discovery.discoveredRadios[0].firmwareVersion))")

      if Api.sharedInstance.connect(discovery.discoveredRadios[0], programName: "v2Tests", isGui: connectAsGui, logState: logState) {
        sleep(2)
        
        Swift.print("***** Connected")
        
        return Api.sharedInstance.radio
      } else {
        XCTFail("***** Failed to connect to Radio *****\n", file: #function)
        return nil
      }
    } else {
      XCTFail("***** No Radio(s) found *****\n", file: #function)
      return nil
    }
  }
  
  func disconnect() {
    Api.sharedInstance.disconnect()
    
    Swift.print("***** Disconnected\n")
  }
  
  override func setUp() {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }
  
  // ------------------------------------------------------------------------------
  // MARK: - AudioStream
  
  private var audioStreamStatus = "0x40000009 dax=3 slice=0 ip=10.0.1.107 port=4124"
  func testAudioStreamParse() {
    
    Swift.print("\n***** \(#function), " + requiredVersion)
    
    let radio = discoverRadio(logState: .limited(to: ["AudioStream.swift"]))
    guard radio != nil else { return }
    
    if radio!.version.isOldApi {
      
      AudioStream.parseStatus(radio!, Array(audioStreamStatus.keyValuesArray()), true)
      sleep(2)
      
      if let object = radio!.audioStreams["0x40000009".streamId!] {
        
        if showInfoMessages { Swift.print("***** AUDIO STREAM object created") }
        
        XCTAssertEqual(object.id, "0x40000009".streamId!)

        XCTAssertEqual(object.daxChannel, 3, "daxChannel", file: #function)
        XCTAssertEqual(object.ip, "10.0.1.107", "ip", file: #function)
        XCTAssertEqual(object.port, 4124, "port", file: #function)
        XCTAssertEqual(object.slice, radio!.slices["0".objectId!], "slice", file: #function)
        
        if showInfoMessages { Swift.print("***** AUDIO STREAM object parameters verified") }
        
      } else {
        XCTFail("***** AUDIO STREAM object NOT created *****", file: #function)
      }
      
    } else {
      XCTFail("***** \(#function) skipped, requires \(requiredVersion)", file: #function)
    }
    disconnect()
  }
  
  func testAudioStream() {
    
    Swift.print("\n***** \(#function), " + requiredVersion)
    
    let radio = discoverRadio(logState: .limited(to: ["AudioStream.swift"]))
    guard radio != nil else { return }
    
    if radio!.version.isOldApi {
      
      // remove all
      radio!.audioStreams.forEach( {$0.value.remove() } )
      sleep(2)
      if radio!.audioStreams.count == 0 {
        
        if showInfoMessages { Swift.print("***** Existing AUDIO STREAM object(s) removed") }
        
        // ask for new
        radio!.requestAudioStream( "2")
        sleep(2)
        
        if showInfoMessages { Swift.print("***** 1st AUDIO STREAM object requested") }
        
        // verify added
        if radio!.audioStreams.count == 1 {
          
          if showInfoMessages { Swift.print("***** 1st AUDIO STREAM object created") }
          
          if let object = radio!.audioStreams.first?.value {
            
            let id = object.id
            let clientHandle = object.clientHandle
            let daxChannel = object.daxChannel
            let ip = object.ip
            let port = object.port
            let slice = object.slice
            
            if showInfoMessages { Swift.print("***** 1st AUDIO STREAM object parameters saved") }
            
            // remove it
            radio!.audioStreams[id]!.remove()
            sleep(2)
            if radio!.audioStreams.count == 0 {
              
              if showInfoMessages { Swift.print("***** 1st AUDIO STREAM object removed") }
              
              // ask for new
              radio!.requestAudioStream( "2")
              sleep(2)
              
              if showInfoMessages { Swift.print("***** 2nd AUDIO STREAM object requested") }
              
              // verify added
              if radio!.audioStreams.count == 1 {
                if let object = radio!.audioStreams.first?.value {
                  
                  if showInfoMessages { Swift.print("***** 2nd AUDIO STREAM object created") }
                  
                  XCTAssertEqual(object.clientHandle, clientHandle, "clientHandle", file: #function)
                  XCTAssertEqual(object.daxChannel, daxChannel, "daxChannel", file: #function)
                  XCTAssertEqual(object.ip, ip, "ip", file: #function)
                  XCTAssertEqual(object.port, port, "port", file: #function)
                  XCTAssertEqual(object.slice, slice, "slice", file: #function)
                  
                  if showInfoMessages { Swift.print("***** 2nd AUDIO STREAM object parameters verified") }
                  
                  object.daxChannel = 4
                  object.ip = "12.2.3.218"
                  object.port = 4214
                  object.slice = radio!.slices["0".objectId!]
                  
                  if showInfoMessages { Swift.print("***** 2nd AUDIO STREAM object parameters modified") }
                  
                  XCTAssertEqual(object.clientHandle, clientHandle, "clientHandle", file: #function)
                  XCTAssertEqual(object.daxChannel, 4, "daxChannel", file: #function)
                  XCTAssertEqual(object.ip, "12.2.3.218", "ip", file: #function)
                  XCTAssertEqual(object.port, 4214, "port", file: #function)
                  XCTAssertEqual(object.slice, radio!.slices["0".objectId!], "slice", file: #function)
                  
                  if showInfoMessages { Swift.print("***** 2nd AUDIO STREAM object modified parameters verified") }
                  
                } else {
                  XCTFail("***** 2nd AUDIO STREAM object NOT found *****", file: #function)
                }
              } else {
                XCTFail("***** 2nd AUDIO STREAM object NOT created", file: #function)
              }
            } else {
              XCTFail("***** 1st AUDIO STREAM object NOT removed", file: #function)
            }
          } else {
            XCTFail("***** 1st AUDIO STREAM object NOT found", file: #function)
          }
        } else {
          XCTFail("***** 1st AUDIO STREAM object NOT created", file: #function)
        }
      } else {
        XCTFail("***** Existing AUDIO STREAM object(s) NOT removed", file: #function)
      }
      // remove all
      radio!.audioStreams.forEach( {$0.value.remove() } )

    } else {
      XCTFail("***** \(#function) skipped, requires \(requiredVersion)", file: #function)
    }
    disconnect()
  }
  
  // ------------------------------------------------------------------------------
  // MARK: - IqStream

  private var iqStreamStatus_1 = "3 pan=0x0 rate=48000 capacity=16 available=16"
  func testIqStreamParse_1() {
    
    Swift.print("\n***** \(#function), " + requiredVersion)
    
    let radio = discoverRadio(logState: .limited(to: ["IqStream.swift"]))
    guard radio != nil else { return }
    
    if radio!.version.isOldApi {

      IqStream.parseStatus(radio!, Array(iqStreamStatus_1.keyValuesArray()), true)
      sleep(2)

      if let object = radio!.iqStreams["3".streamId!] {

        if showInfoMessages { Swift.print("***** IQ STREAM object created") }

        XCTAssertEqual(object.id, "3".streamId!)

        XCTAssertEqual(object.available, 16, "available", file: #function)
        XCTAssertEqual(object.capacity, 16, "capacity", file: #function)
        XCTAssertEqual(object.pan, "0x0".streamId!, "pan", file: #function)
        XCTAssertEqual(object.rate, 48_000, "rate", file: #function)

        if showInfoMessages { Swift.print("***** IQ STREAM object parameters verified") }

      } else {
        XCTFail("***** IQ STREAM object NOT created *****", file: #function)
      }

    } else {
      XCTFail("***** \(#function) skipped, requires \(requiredVersion)", file: #function)
    }
    disconnect()
  }

  private var iqStreamStatus_2 = "3 daxiq=4 pan=0x0 rate=48000 ip=10.0.1.100 port=4992 streaming=1 capacity=16 available=16"
  func testIqStreamParse_2() {
    
    Swift.print("\n***** \(#function), " + requiredVersion)
    
    let radio = discoverRadio(logState: .limited(to: ["IqStream.swift"]))
    guard radio != nil else { return }
    
    if radio!.version.isOldApi {

      IqStream.parseStatus(radio!, Array(iqStreamStatus_2.keyValuesArray()), true)
      sleep(2)

      if let object = radio!.iqStreams["3".streamId!] {

        if showInfoMessages { Swift.print("***** IQ STREAM object created") }

        XCTAssertEqual(object.id, "3".streamId!)

        XCTAssertEqual(object.available, 16, "available", file: #function)
        XCTAssertEqual(object.capacity, 16, "capacity", file: #function)
        XCTAssertEqual(object.pan, "0x0".streamId!, "pan", file: #function)
        XCTAssertEqual(object.rate, 48_000, "rate", file: #function)
        XCTAssertEqual(object.ip, "10.0.1.100", "ip", file: #function)
        XCTAssertEqual(object.port, 4992, "port", file: #function)
        XCTAssertEqual(object.streaming, true, "streaming", file: #function)

        if showInfoMessages { Swift.print("***** IQ STREAM object parameters verified") }

      } else {
        XCTFail("***** IQ STREAM object NOT created *****", file: #function)
      }

    } else {
      XCTFail("***** \(#function) skipped, requires \(requiredVersion)", file: #function)
    }
    disconnect()
  }

  private var iqStreamStatus_3 = "3 daxiq=4 pan=0x0 daxiq_rate=48000 capacity=16 available=16"
  func testIqStreamParse3() {
    
    Swift.print("\n***** \(#function), " + requiredVersion)
    
    let radio = discoverRadio(logState: .limited(to: ["IqStream.swift"]))
    guard radio != nil else { return }
    
    if radio!.version.isOldApi {

      IqStream.parseStatus(radio!, Array(iqStreamStatus_3.keyValuesArray()), true)
      sleep(2)

      if let object = radio!.iqStreams["3".streamId!] {

        if showInfoMessages { Swift.print("***** IQ STREAM object created") }

        XCTAssertEqual(object.id, "3".streamId!)

        XCTAssertEqual(object.available, 16, "available", file: #function)
        XCTAssertEqual(object.capacity, 16, "capacity", file: #function)
        XCTAssertEqual(object.pan, "0x0".streamId!, "pan", file: #function)
        XCTAssertEqual(object.rate, 48_000, "rate", file: #function)

        if showInfoMessages { Swift.print("***** IQ STREAM object parameters verified") }

      } else {
        XCTFail("***** IQ STREAM object NOT created *****", file: #function)
      }

    } else {
      XCTFail("***** \(#function) skipped, requires \(requiredVersion)", file: #function)
    }
    disconnect()
  }

  func testIqStream() {
    
    Swift.print("\n***** \(#function), " + requiredVersion)
    
    let radio = discoverRadio(logState: .limited(to: ["IqStream.swift"]))
    guard radio != nil else { return }
    
    if radio!.version.isOldApi {
      
      // remove all
      radio!.iqStreams.forEach { $0.value.remove() }
      sleep(2)
      if radio!.iqStreams.count == 0 {
        
        if showInfoMessages { Swift.print("***** Existing IQ STREAM object(s) removed") }
        
        // get new
        radio!.requestIqStream("3")
        sleep(2)
        
        if showInfoMessages { Swift.print("***** 1st IQ STREAM object requested") }
        
        // verify added
        if radio!.iqStreams.count == 1 {
          
          if let object = radio!.iqStreams.first?.value {
            
            if showInfoMessages { Swift.print("***** 1st IQ STREAM object created") }
            
            let id            = object.id
            
            let available     = object.available
            let capacity      = object.capacity
            let pan           = object.pan
            let rate          = object.rate
            
            if showInfoMessages { Swift.print("***** 1st IQ STREAM object parameters saved") }
            
            // remove it
            radio!.iqStreams[id]!.remove()
            sleep(2)
            
            if radio!.iqStreams.count == 0 {
              
              if showInfoMessages { Swift.print("***** 1st IQ STREAM object removed") }
              
              // get new
              radio!.requestIqStream("3")
              sleep(2)
              
              if showInfoMessages { Swift.print("***** 2nd IQ STREAM object requested") }
              
              // verify added
              if radio!.iqStreams.count == 1 {
                if let object = radio!.iqStreams.first?.value {
                  
                  if showInfoMessages { Swift.print("***** 2nd IQ STREAM object created") }
                  
                  XCTAssertEqual(object.available, available, "available", file: #function)
                  XCTAssertEqual(object.capacity, capacity, "capacity", file: #function)
                  XCTAssertEqual(object.pan, pan, "pan", file: #function)
                  XCTAssertEqual(object.rate, rate, "rate", file: #function)
                  
                  if showInfoMessages { Swift.print("***** 2nd IQ STREAM object parameters verified") }
                  
                  object.rate = rate * 2
                  
                  if showInfoMessages { Swift.print("***** 2nd IQ STREAM object parameters modified") }
                  
                  XCTAssertEqual(object.available, available, "available", file: #function)
                  XCTAssertEqual(object.capacity, capacity, "capacity", file: #function)
                  XCTAssertEqual(object.pan, pan, "pan", file: #function)
                  XCTAssertEqual(object.rate, rate * 2, "rate", file: #function)
                  
                  if showInfoMessages { Swift.print("***** 2nd IQ STREAM object modified parameters verified") }
                  
                } else {
                  XCTFail("***** 2nd IQ STREAM object NOT found *****", file: #function)
                }
              } else {
                XCTFail("***** 2nd IQ STREAM object NOT added *****", file: #function)
              }
            } else {
              XCTFail("***** 1st IQ STREAM object NOT removed *****", file: #function)
            }
          } else {
            XCTFail("***** 1st IQ STREAM object NOT found *****", file: #function)
          }
        } else {
          XCTFail("***** 1st IQ STREAM object NOT created *****", file: #function)
        }
      } else {
        XCTFail("***** Existing IQ STREAM object(s) NOT removed *****", file: #function)
      }
      // remove all
      radio!.iqStreams.forEach { $0.value.remove() }
      
    } else {
      XCTFail("***** \(#function) skipped, requires \(requiredVersion)", file: #function)
    }
    disconnect()
  }
  
  // ------------------------------------------------------------------------------
  // MARK: - MicAudioStream
  
  private var micAudioStreamStatus = "0x04000009 in_use=1 ip=192.168.1.162 port=4991"
  func testMicAudioStreamParse() {
    
    Swift.print("\n***** \(#function), " + requiredVersion)
    
    let radio = discoverRadio(logState: .limited(to: ["MicAudioStream.swift"]))
    guard radio != nil else { return }
    
    if radio!.version.isOldApi {
      
      MicAudioStream.parseStatus(radio!, micAudioStreamStatus.keyValuesArray(), true)
      sleep(2)
      
      if let object = radio!.micAudioStreams["0x04000009".streamId!] {
        
        if showInfoMessages { Swift.print("***** MIC AUDIO STREAM object created") }
        
        XCTAssertEqual(object.id, "0x04000009".streamId!, file: #function)

        XCTAssertEqual(object.ip, "192.168.1.162", "ip", file: #function)
        XCTAssertEqual(object.port, 4991, "port", file: #function)
        
        if showInfoMessages { Swift.print("***** MIC AUDIO STREAM object Properties verified") }
        
      } else {
        XCTFail("***** MIC AUDIO STREAM object NOT created", file: #function)
      }
      
    } else {
      XCTFail("***** \(#function) skipped, requires \(requiredVersion)", file: #function)
    }
    disconnect()
  }
  
  func testMicAudioStream() {
    
    Swift.print("\n***** \(#function), " + requiredVersion)
    
    let radio = discoverRadio(logState: .limited(to: ["MicAudioStream.swift"]))
    guard radio != nil else { return }
    
    if radio!.version.isOldApi {
      
      // remove all
      radio!.micAudioStreams.forEach( {$0.value.remove() } )
      sleep(2)
      if radio!.micAudioStreams.count == 0 {
        
        if showInfoMessages { Swift.print("***** Existing MIC AUDIO STREAM object(s) removed") }
        
        // ask new
        radio!.requestMicAudioStream()
        sleep(2)
        
        if showInfoMessages { Swift.print("***** 1st MIC AUDIO STREAM object requested") }
        
        // verify added
        if radio!.micAudioStreams.count == 1 {
          
          if showInfoMessages { Swift.print("***** 1st MIC AUDIO STREAM object created") }
          
          if let object = radio!.micAudioStreams.first?.value {
            
            let id = object.id
            
            let ip = object.ip
            let port = object.port
            
            if showInfoMessages { Swift.print("***** 1st MIC AUDIO STREAM object parameters saved") }
            
            // remove it
            radio!.micAudioStreams[id]!.remove()
            sleep(2)
            
            if radio!.micAudioStreams.count == 0 {
              
              if showInfoMessages { Swift.print("***** 1st MIC AUDIO STREAM object removed") }
              
              // ask new
              radio!.requestMicAudioStream()
              sleep(2)
              
              if showInfoMessages { Swift.print("***** 2nd MIC AUDIO STREAM object requested") }
              
              // verify added
              if radio!.micAudioStreams.count == 1 {
                if let object = radio!.micAudioStreams.first?.value {
                  
                  if showInfoMessages { Swift.print("***** 2nd MIC AUDIO STREAM object created") }
                  
                  XCTAssertEqual(object.ip, ip, "ip", file: #function)
                  XCTAssertEqual(object.port, port, "port", file: #function)
                  
                  if showInfoMessages { Swift.print("***** 2nd MIC AUDIO STREAM object parameters verified") }
                  
                  object.ip = "12.2.3.218"
                  object.port = 4214
                  
                  if showInfoMessages { Swift.print("***** 2nd MIC AUDIO STREAM object parameters modified") }
                  
                  XCTAssertEqual(object.ip, "12.2.3.218", "ip", file: #function)
                  XCTAssertEqual(object.port, 4214, "port", file: #function)
                  
                  if showInfoMessages { Swift.print("***** 2nd MIC AUDIO STREAM object modified parameters verified") }
                  
                } else {
                  XCTFail("***** 2nd MIC AUDIO STREAM object NOT removed *****", file: #function)
                }
              } else {
                XCTFail("***** 2nd MIC AUDIO STREAM object NOT added *****", file: #function)
              }
            } else {
              XCTFail("***** 1st MIC AUDIO STREAM object NOT removed *****", file: #function)
            }
          } else {
            XCTFail("***** 1st MIC AUDIO STREAM object NOT found *****", file: #function)
          }
        } else {
          XCTFail("***** 1st MIC AUDIO STREAM object NOT added *****", file: #function)
        }
      } else {
        XCTFail("***** Existing MIC AUDIO STREAM object(s) NOT removed *****", file: #function)
      }
      // remove all
      radio!.iqStreams.forEach { $0.value.remove() }
      
    } else {
      XCTFail("***** \(#function) skipped, requires \(requiredVersion)", file: #function)
    }
    disconnect()
  }
  
  // ------------------------------------------------------------------------------
  // MARK: - TxAudioStream
  
  private var txAudioStreamStatus = "0x84000000 in_use=1 dax_tx=0 ip=192.168.1.162 port=4991"
  
  func testTxAudioStreamParse() {
    
    Swift.print("\n***** \(#function), " + requiredVersion)
    
    let radio = discoverRadio(logState: .limited(to: ["TxAudioStream.swift"]))
    guard radio != nil else { return }
    
    if radio!.version.isOldApi {
      
        TxAudioStream.parseStatus(radio!, txAudioStreamStatus.keyValuesArray(), true)
        sleep(2)
        
        if let object = radio!.txAudioStreams["0x84000000".streamId!] {
          
          if showInfoMessages { Swift.print("***** TX AUDIO STREAM object created") }
          
          XCTAssertEqual(object.ip, "192.168.1.162", "ip", file: #function)
          XCTAssertEqual(object.port, 4991, "port", file: #function)
          XCTAssertEqual(object.transmit, false, "transmit", file: #function)
          
          if showInfoMessages { Swift.print("***** TX AUDIO STREAM object Properties verified") }
                    
        } else {
          XCTFail("***** TX AUDIO STREAM object NOT created *****", file: #function)
        }
    } else {
      XCTFail("***** \(#function) skipped, requires \(requiredVersion)", file: #function)
    }
    disconnect()
  }
  
  func testTxAudioStream() {
    
    Swift.print("\n***** \(#function), " + requiredVersion)
    
    let radio = discoverRadio(logState: .limited(to: ["TxAudioStream.swift"]))
    guard radio != nil else { return }
    
    if radio!.version.isOldApi {
      
      // remove all
      radio!.txAudioStreams.forEach( {$0.value.remove() } )
      sleep(2)
      if radio!.txAudioStreams.count == 0 {
        
        if showInfoMessages { Swift.print("***** Existing TX AUDIO STREAM object(s) removed") }

        // ask for a new AudioStream
        radio!.requestTxAudioStream()
        sleep(2)
        
        if showInfoMessages { Swift.print("***** 1st TX AUDIO STREAM object requested") }
        
        // verify AudioStream added
        if radio!.txAudioStreams.count == 1 {
          
          if showInfoMessages { Swift.print("***** 1st TX AUDIO STREAM object created") }
          
          if let object = radio!.txAudioStreams.first?.value {
            
            let id = object.id
            
            let transmit = object.transmit
            let ip = object.ip
            let port = object.port
            
            if showInfoMessages { Swift.print("***** 1st TX AUDIO STREAM object parameters saved") }
            
            // remove it
            radio!.txAudioStreams[id]!.remove()
            sleep(2)
            if radio!.txAudioStreams.count == 0 {
              
              if showInfoMessages { Swift.print("***** 1st TX AUDIO STREAM object removed") }
              
              // ask new
              radio!.requestTxAudioStream()
              sleep(2)
              
              if showInfoMessages { Swift.print("***** 2nd TX AUDIO STREAM object requested") }
              
              // verify added
              if radio!.txAudioStreams.count == 1 {
                
                if let object = radio!.txAudioStreams.first?.value {
                  
                  if showInfoMessages { Swift.print("***** 2nd TX AUDIO STREAM object created") }
                  
                  XCTAssertEqual(object.transmit, transmit, "transmit", file: #function)
                  XCTAssertEqual(object.ip, ip, "ip", file: #function)
                  XCTAssertEqual(object.port, port, "port", file: #function)
                  
                  if showInfoMessages { Swift.print("***** 2nd TX AUDIO STREAM object parameters verified") }
                  
                  // change properties
                  object.transmit = false
                  object.ip = "12.2.3.218"
                  object.port = 4214
                  
                  if showInfoMessages { Swift.print("***** 2nd TX AUDIO STREAM object parameters modified") }
                  
                  // re-verify properties
                  XCTAssertEqual(object.transmit, false, "transmit", file: #function)
                  XCTAssertEqual(object.ip, "12.2.3.218", "ip", file: #function)
                  XCTAssertEqual(object.port, 4214, "port", file: #function)
                  
                  if showInfoMessages { Swift.print("***** 2nd TX AUDIO STREAM object modified parameters verified") }
                  
                } else {
                  XCTFail("***** 2nd TX AUDIO STREAM object NOT found *****", file: #function)
                }
              } else {
                XCTFail("***** 2nd TX AUDIO STREAM object NOT added *****", file: #function)
              }
            } else {
              XCTFail("***** 1st TX AUDIO STREAM object NOT removed *****", file: #function)
            }
          } else {
            XCTFail("***** 1st TX AUDIO STREAM object NOT found *****", file: #function)
          }
        } else {
          XCTFail("***** 1st TX AUDIO STREAM object NOT created *****", file: #function)
        }
      } else {
        XCTFail("***** Existing TX AUDIO STREAM object(s) NOT removed *****", file: #function)
      }
      // remove all
      radio!.txAudioStreams.forEach { $0.value.remove() }

    } else {
      XCTFail("***** \(#function) skipped, requires \(requiredVersion)", file: #function)
    }
    disconnect()
  }
  
  // ------------------------------------------------------------------------------
  // MARK: - Opus
 
  ///   Format:  <streamId, > <"ip", ip> <"port", port> <"opus_rx_stream_stopped", 1|0>  <"rx_on", 1|0> <"tx_on", 1|0>

  private let opusStatus = "0x50000000 ip=10.0.1.100 port=4993 opus_rx_stream_stopped=0 rx_on=0 tx_on=0"
  func testOpusParse() {
    Swift.print("\n***** \(#function), " + requiredVersion)
    
    let radio = discoverRadio(logState: .limited(to: ["Opus.swift"]))
    guard radio != nil else { return }
    
    if radio!.version.isOldApi {

      Opus.parseStatus(radio!, Array(opusStatus.keyValuesArray()), true)
      sleep(2)

      if let object = radio!.opusStreams["0x50000000".streamId!] {

        if showInfoMessages { Swift.print("***** OPUS STREAM object created") }

        XCTAssertEqual(object.id, "0x50000000".streamId!, file: #function)

        XCTAssertEqual(object.ip, "10.0.1.100", "ip", file: #function)
        XCTAssertEqual(object.port, 4993, "port", file: #function)
        XCTAssertEqual(object.rxStopped, false, "rxStopped", file: #function)
        XCTAssertEqual(object.rxEnabled, false, "rxEnabled", file: #function)
        XCTAssertEqual(object.txEnabled, false, "txEnabled", file: #function)

        if showInfoMessages { Swift.print("***** OPUS STREAM object parameters verified") }

      } else {
        XCTFail("***** OPUS STREAM object NOT created *****", file: #function)
      }

    } else {
      XCTFail("***** \(#function) skipped, requires \(requiredVersion)", file: #function)
    }
    disconnect()

  }
  
  func testOpus() {
    
    Swift.print("\n***** \(#function), " + requiredVersion)
    
    let radio = discoverRadio(logState: .limited(to: ["Opus.swift"]))
    guard radio != nil else { return }
    
    if radio!.version.isOldApi {
      
      // verify added
      if radio!.opusStreams.count == 1 {
        
        if let object = radio!.opusStreams.first?.value {
          
          if showInfoMessages { Swift.print("***** OPUS STREAM object found") }
          
          let rxStopped = object.rxStopped
          let rxEnabled = object.rxEnabled
          let txEnabled = object.txEnabled

          if showInfoMessages { Swift.print("***** OPUS STREAM object parameters saved") }
          
          object.ip = "10.0.1.100"
          object.port = 5_000
          object.rxStopped = !rxStopped
          object.rxEnabled = !rxEnabled
          object.txEnabled = !txEnabled
          
          if showInfoMessages { Swift.print("***** OPUS STREAM object parameters modified") }
          
          XCTAssertEqual(object.ip, "10.0.1.100", "ip", file: #function)
          XCTAssertEqual(object.port, 5_000, "port", file: #function)
          XCTAssertEqual(object.rxStopped, !rxStopped, "rxStopped", file: #function)
          XCTAssertEqual(object.rxEnabled, !rxEnabled, "rxEnabled", file: #function)
          XCTAssertEqual(object.txEnabled, !txEnabled, "txEnabled", file: #function)

          if showInfoMessages { Swift.print("***** OPUS STREAM object modified parameters verified") }
          
        } else {
          XCTFail("***** OPUS STREAM object NOT found *****", file: #function)
        }
      } else {
        XCTFail("***** OPUS STREAM object does NOT exist *****", file: #function)
      }
      
    } else {
      XCTFail("***** \(#function) skipped, requires \(requiredVersion)", file: #function)
    }
    disconnect()
  }
}
