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

class DoctorViewController: UITableViewController {
    
    let disposeBag = DisposeBag()
    var datasource: [DoctorModel] = []{
        didSet{
            self.tableView.reloadData()
        }
    }
    
    lazy var indicatorView: UIActivityIndicatorView = {
        
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .White)
        indicator.hidesWhenStopped = true
        indicator.startAnimating()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: indicator)
        return indicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.indicatorView.startAnimating()
        getDoctors()
    }
    
    func getDoctors(){
        
        APIProvider.shareProvider.rx_JSON(MHealthAPI.Doctors.method, MHealthAPI.Doctors)
        .observeOn(MainScheduler.instance)
        .debug()
        .subscribe {[weak self] (event) in
            switch event{
            case .Next:
                print(event.element?.valueForKey("data"))
                self?.datasource = Mapper<DoctorModel>().mapArray(event.element?.valueForKey("data")) ?? []
                
                //Import doctors
                guard let data = event.element?.valueForKey("data") as? [[NSObject: AnyObject]] else{
                    return
                }
                MagicalRecord.saveWithBlock({ (context) in
                    DoctorModel.MR_importFromArray(data, inContext: context)
                }) { (done, error) in
                    print("save done with: " + (error?.localizedDescription ?? "no error"))
                }
                
            case .Completed:
                self?.indicatorView.stopAnimating()
                break
            case .Error:
                print(event.error)
                break
            }
        }
        .addDisposableTo(disposeBag)
    }
    
    @IBAction func saveDoctors(sender: AnyObject?){
        
        
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
