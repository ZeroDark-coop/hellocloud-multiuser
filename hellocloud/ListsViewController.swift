/// ZeroDark.cloud
///
/// Homepage      : https://www.zerodark.cloud
/// GitHub        : https://github.com/4th-ATechnologies/ZeroDark.cloud
/// Documentation : https://zerodarkcloud.readthedocs.io/en/latest
/// API Reference : https://apis.zerodark.cloud
///
/// Sample App: helloccloud

import UIKit
import YapDatabase
import ZeroDarkCloud

 protocol ListTableCellDelegate: class {

 }

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// MARK: -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

class ListsViewController: UIViewController,
SettingsViewControllerDelegate  {
	
	var uiDatabaseConnection: YapDatabaseConnection!
	var mappings: YapDatabaseViewMappings?
	var btnTitle: IconTitleButton?
    
	var localUserID: String = ""
    
	@IBOutlet public var listsTable : UITableView!
	
	// for simulating push
	@IBOutlet public var vwSimulate : UIView!
	@IBOutlet public var cnstVwSimulateHeight : NSLayoutConstraint!
	
    
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// MARK: Class Functions
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	class func allListsWithLocalUserID(userID: String, transaction:YapDatabaseReadTransaction ) -> [String] {
        
		var result:[String] = []
        
		 
		return result
	}
    
	class func initWithLocalUserID(_ localUserID: String) -> ListsViewController {
		
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		let vc = storyboard.instantiateViewController(withIdentifier: "ListsViewController") as? ListsViewController
		
		vc?.localUserID = localUserID
		
		return vc!
	}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// MARK: View Lifecycle
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let settingsImage = UIImage(named: "threebars")!.withRenderingMode(.alwaysTemplate)
		
		let settingButton = UIButton()
		settingButton.setImage(settingsImage, for: .normal)
		settingButton.addTarget( self,
		                 action: #selector(self.didHitSettings(_:)),
		                    for: .touchUpInside)
		
		let settingButtonItem = UIBarButtonItem(customView: settingButton)
		let width1 = settingButtonItem.customView?.widthAnchor.constraint(equalToConstant: 22)
		width1?.isActive = true
		let height1 = settingButtonItem.customView?.heightAnchor.constraint(equalToConstant: 22)
		height1?.isActive = true
		
		self.navigationItem.leftBarButtonItems = [
			settingButtonItem
		]
		
		let sortImage = UIImage(named: "hamburger")!.withRenderingMode(.alwaysTemplate)
		
		let sortButton = UIButton()
		sortButton.setImage(sortImage, for: .normal)
		sortButton.addTarget( self,
		              action: #selector(self.didSetEditing(_:)),
		                 for: .touchUpInside)
		
		let sortButtonItem = UIBarButtonItem(customView: sortButton)
		let width = sortButtonItem.customView?.widthAnchor.constraint(equalToConstant: 22)
		width?.isActive = true
		let height = sortButtonItem.customView?.heightAnchor.constraint(equalToConstant: 22)
		height?.isActive = true
        
		self.navigationItem.rightBarButtonItems = [
            
			UIBarButtonItem(barButtonSystemItem: .add,
			                             target: self,
			                             action: #selector(self.didTapAddItemButton(_:))),
			sortButtonItem
		]
		
	#if DEBUG
		
		self.vwSimulate.isHidden = false
		self.cnstVwSimulateHeight.constant = 44
		
		let zdc = ZDCManager.zdc()
		if let simVC = zdc.uiTools?.simulatePushNotificationViewController() {
			
			simVC.view.frame = self.vwSimulate.bounds;
			simVC.willMove(toParent: self)
			self.vwSimulate.addSubview(simVC.view)
			self.addChild(simVC)
			simVC.didMove(toParent: self)
		}
		
	#else
		
		self.vwSimulate.isHidden = true
		self.cnstVwSimulateHeight.constant = 0
	
	#endif
	}
    
	override func viewWillAppear(_ animated: Bool) {
        
			self.setupDatabaseConnection()
			
		var localUser: ZDCLocalUser?
		uiDatabaseConnection.read {(transaction) in
			
			localUser = transaction.localUser(id: self.localUserID)
		}
		
		if let localUser = localUser {
			self.setNavigationTitle(user: localUser)
		}
	//	listsTable.reloadData()
	}
	
	override func viewDidDisappear(_ animated: Bool) {
	
		NotificationCenter.default.removeObserver(self)
	}
    
	private func setNavigationTitle(user: ZDCLocalUser) {
		
		if (btnTitle == nil) {
			
			btnTitle = IconTitleButton.create()
			btnTitle?.setTitleColor(self.view.tintColor, for: .normal)
			btnTitle?.addTarget(self,
			                    action: #selector(self.didHitTitle(_:)),
			                       for: .touchUpInside)
		}
		
		btnTitle?.setTitle(user.displayName, for: .normal)
		btnTitle?.isEnabled = true
		self.navigationItem.titleView = btnTitle
		
		let zdc = ZDCManager.zdc()
		
		let size = CGSize(width: 30, height: 30)
		let defaultImage = { () -> UIImage in
			return zdc.imageManager!.defaultUserAvatar().scaled(to: size, scalingMode: .aspectFill)
		}
		let processing = {(image: UIImage) in
			return image.scaled(to: size, scalingMode: .aspectFill)
		}
		let preFetch = {[weak self](image: UIImage?, willFetch: Bool) -> Void in
			self?.btnTitle?.setImage(image ?? defaultImage(), for: .normal)
		}
		let postFetch = {[weak self](image: UIImage?, error: Error?) -> Void in
			self?.btnTitle?.setImage(image ?? defaultImage(), for: .normal)
		}
		
		zdc.imageManager!.fetchUserAvatar( user,
		                             with: nil,
		                     processingID: "30*30",
		                  processingBlock: processing,
		                         preFetch: preFetch,
		                        postFetch: postFetch)
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// MARK: Database
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		private func setupDatabaseConnection() {
			
			let zdc = ZDCManager.zdc()
			
			uiDatabaseConnection = zdc.databaseManager?.uiDatabaseConnection
	 
			NotificationCenter.default.addObserver( self,
													selector: #selector(self.databaseConnectionDidUpdate(notification:)),
														 name: .UIDatabaseConnectionDidUpdate,
													  object: nil)
		}
		 
		@objc func databaseConnectionDidUpdate(notification: Notification) {
			  
	
		}
		 
			
	
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// MARK: Utilities
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// MARK: Actions
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	@objc func didHitTitle(_ sender: Any) {
		
		let zdc = ZDCManager.zdc()
		zdc.uiTools?.pushSettings(forLocalUserID: localUserID, with: self.navigationController!)
	}
    
	@objc func didHitSettings(_ sender: Any) {
		
		AppDelegate.sharedInstance().toggleSettingsView()
	}
	
	@objc func didSetEditing(_ sender: Any) {
		
		let willEdit = !self.isEditing
		self.setEditing(willEdit, animated: true)
	}
    
    @objc func didTapAddItemButton(_ sender: Any)
    {
        
        self.setEditing(false, animated: true)
   
    }
    



}
