//
//  DoctorViewController.swift
//  MHealth
//
//  Created by SuLT on 6/30/16.
//  Copyright © 2016 MHealth. All rights reserved.
//

import UIKit
import RxSwift
import RxAlamofire
import ObjectMapper
import MagicalRecord
import ReachabilitySwift
import SwiftOverlays

class DoctorViewController: UITableViewController {
    
    let disposeBag = DisposeBag()
    var datasource: [DoctorModel] = []{
        didSet{
            self.tableView.reloadData()
        }
    }
    lazy var reachability = try! Reachability.reachabilityForInternetConnection()
    
    deinit{
        reachability.stopNotifier()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        observeNetwork()
        self.getDoctors()

    }
    
    func observeNetwork() {
        reachability.whenReachable = { reachability in
            dispatch_async(dispatch_get_main_queue(), {
                if reachability.isReachableViaWiFi(){
                    self.showTextOverlay("Required on celular network")
                }else{
                    self.getDoctors()
                }
            })
        }
        
        reachability.whenUnreachable = { reachability in
            dispatch_async(dispatch_get_main_queue(), {
                self.showTextOverlay("Please check your network")
            })
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    func getDoctors(){
        
        ///Cancel previous requests if needs
//        APIProvider.shareProvider.session.invalidateAndCancel()
        
        self.showWaitOverlayWithText("Please wait...")
        ///
        APIProvider.shareProvider.rx_JSON(MHealthAPI.Doctors.method, MHealthAPI.Doctors)
        .observeOn(MainScheduler.instance)
        .debug()
        .subscribe {[weak self] (event) in
            switch event{
            case .Next:
                
                self?.datasource = Mapper<DoctorModel>().mapArray(event.element?.valueForKey("data")) ?? []
            
                guard let data = event.element?.valueForKey("data") as? [[NSObject: AnyObject]] else{
                    return
                }
                MagicalRecord.saveWithBlock({ (context) in
                    DoctorModel.MR_importFromArray(data, inContext: context)
                }) { (done, error) in
                    print("save done with: " + (error?.localizedDescription ?? "no error"))
                    print(DoctorModel.MR_findAll())
                }
                
                ///
            case .Completed:
                self?.removeAllOverlays()
                break
            case .Error:
                print(event.error)
                break
            }
        }
        .addDisposableTo(disposeBag)
    }
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.datasource.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DoctorCell", forIndexPath: indexPath)
        let model = self.datasource[indexPath.row]
        cell.textLabel?.text = model.name
        cell.detailTextLabel?.text = model.type

        return cell
    }
    
}
