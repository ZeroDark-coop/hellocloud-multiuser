//
//  ZDCManager.swift
//  helloworld
//
//  Created by Vincent Moscaritolo on 2/13/20.
//  Copyright © 2020 no name. All rights reserved.
//

import Foundation

import ZeroDarkCloud

/// The treeID must first be registered in the [dashboard](https://dashboard.zerodark.cloud).
/// More instructions about this can be found via
/// the [docs](https://zerodarkcloud.readthedocs.io/en/latestclient/setup_1/).
///

let kZDC_TreeID = "coop.zerodark.hellocloud"

/// ZDCManager is our interface into the ZeroDarkCloud framework.
///
/// This class demonstrates much of the functionality you'll use within your own app, such as:
/// - setting up the ZeroDark database
/// - implementing the methods required by the ZeroDarkCloudDelegate protocol
/// - providing the data that ZeroDark uploads to the cloud
/// - downloading nodes from the ZeroDark cloud treesystem
///
class ZDCManager: ZeroDarkCloudDelegate {

	var zdc: ZeroDarkCloud!
	
	private init() {
		  let config = ZDCConfig(primaryTreeID: kZDC_TreeID)

		  zdc = ZeroDarkCloud(delegate: self, config: config)
		  do {
			 let dbEncryptionKey = try zdc.databaseKeyManager.unlockUsingKeychain()
			 let dbConfig = ZDCDatabaseConfig(encryptionKey: dbEncryptionKey)

			 try zdc.unlockOrCreateDatabase(dbConfig)
		  } catch {
			 print("Something went wrong: \(error)")
		  }

		  // zdc instance is now running & ready for use !
		}

	public static var sharedInstance: ZDCManager = {
		let zdcManager = ZDCManager()
		return zdcManager
	}()
	
	/// Returns the ZeroDarkCloud instance used by the app.
	///
	class func zdc() -> ZeroDarkCloud {
		return ZDCManager.sharedInstance.zdc
	}

	  // MARK: ZeroDarkCloudDelegate protocol

	func data(for node: ZDCNode, at path: ZDCTreesystemPath, transaction: YapDatabaseReadTransaction) -> ZDCData {
			return ZDCData()
	}

	  // Other protocol stubs here...
	func metadata(for node: ZDCNode, at path: ZDCTreesystemPath, transaction: YapDatabaseReadTransaction) -> ZDCData? {
		return nil
	}
	
	func thumbnail(for node: ZDCNode, at path: ZDCTreesystemPath, transaction: YapDatabaseReadTransaction) -> ZDCData? {
		return nil
	}
	
	func didPushNodeData(_ node: ZDCNode, at path: ZDCTreesystemPath, transaction: YapDatabaseReadWriteTransaction) {
		
	}
	
	func didPushNodeData(_ message: ZDCNode, toRecipient recipient: ZDCUser, transaction: YapDatabaseReadWriteTransaction) {
		
	}
	
	func didDiscoverNewNode(_ node: ZDCNode, at path: ZDCTreesystemPath, transaction: YapDatabaseReadWriteTransaction) {
		
	}
	
	func didDiscoverModifiedNode(_ node: ZDCNode, with change: ZDCNodeChange, at path: ZDCTreesystemPath, transaction: YapDatabaseReadWriteTransaction) {
		
	}
	
	func didDiscoverMovedNode(_ node: ZDCNode, from oldPath: ZDCTreesystemPath, to newPath: ZDCTreesystemPath, transaction: YapDatabaseReadWriteTransaction) {
		
	}
	
	func didDiscoverDeletedNode(_ node: ZDCNode, at path: ZDCTreesystemPath, timestamp: Date?, transaction: YapDatabaseReadWriteTransaction) {
		
	}
	
	func didDiscoverConflict(_ conflict: ZDCNodeConflict, forNode node: ZDCNode, atPath path: ZDCTreesystemPath, transaction: YapDatabaseReadWriteTransaction) {
		
	}
	

}
