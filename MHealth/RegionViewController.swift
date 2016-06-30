//
//  RegionViewController.swift
//  MHealth
//
//  Created by SuLT on 6/30/16.
//  Copyright © 2016 MHealth. All rights reserved.
//

import UIKit
import MapKit
import RxMKMapView
import ReachabilitySwift
import SwiftOverlays
import RxSwift
import RxAlamofire
import AudioToolbox
import ObjectMapper
import RxPermission
import Permission
import ChameleonFramework

class RegionViewController: UIViewController {
    let disposeBag = DisposeBag()
    lazy var reachability = try! Reachability.reachabilityForInternetConnection()
    
    deinit{
        reachability.stopNotifier()
        stopTracking()
    }

    @IBOutlet weak var mapView: MKMapView!
    private let locationManager = CLLocationManager()
    private var circularRegion: CLCircularRegion?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        observeNotificationsPermission()
        startLocationTracking()
        
        observeNetwork()
    }

    
    func observeNetwork() {
        reachability.whenReachable = { reachability in
            dispatch_async(dispatch_get_main_queue(), {
                if reachability.isReachableViaWiFi(){
                    self.getWarningRegion()
                }else{
                    self.showTextOverlay("Required on WIFI network")
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
    
    func observeNotificationsPermission(){
        Permission.Notifications(categories: nil)
            .rx_permission
            .debug()
            .observeOn(MainScheduler.instance)
            .subscribeNext {[weak self] (status) in
                switch status{
                case .Authorized:
                    break
                default:
                    self?.showTextOverlay("Please grant notification permission")
                    break
                }
            }
            .addDisposableTo(disposeBag)
    }
    
    func getWarningRegion() {
        
//        APIProvider.shareProvider.session.invalidateAndCancel()
        
        showWaitOverlayWithText("Please wait...")
        
        APIProvider.shareProvider.rx_JSON(MHealthAPI.Location.method, MHealthAPI.Location)
        .observeOn(MainScheduler.instance)
        .debug()
        .subscribe {[weak self] (event) in
            switch event{
            case .Next:
                
                if let region = Mapper<RegionModel>().map(event.element?.valueForKey("data")){
                    self?.startRegionTracking(region)
                }
                ///
                break
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
    
    func setMapRegion(region: RegionModel) {
        let coordinate = CLLocationCoordinate2D(latitude: region.lattitude, longitude: region.longtitude)
        
        var trackRegion = MKCoordinateRegionMakeWithDistance(coordinate, region.radius * 5, region.radius * 5)
        trackRegion = mapView.regionThatFits(trackRegion)
        mapView.setRegion(trackRegion, animated: true)
    }

    
    func addRegionOverlay(region: RegionModel){
        let coordinate = CLLocationCoordinate2D(latitude: region.lattitude, longitude: region.longtitude)
        
        let circleOverlay = MKCircle(centerCoordinate: coordinate, radius: region.radius)
        circleOverlay.title = "Tracked Region"
        mapView.addOverlay(circleOverlay)
    }
    
    func startLocationTracking(){

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        mapView.userTrackingMode = MKUserTrackingMode.FollowWithHeading
        mapView.showsUserLocation = true
    }
    
    func startRegionTracking(region: RegionModel) {
        guard CLLocationManager.isMonitoringAvailableForClass(CLCircularRegion) else {
            self.showTextOverlay("Circular region is not supported on this device!")
            return
        }
        
        setMapRegion(region)
        
        addRegionOverlay(region)
        
        let center = CLLocationCoordinate2D(latitude: region.lattitude, longitude: region.longtitude)
        circularRegion = CLCircularRegion(center: center, radius: region.radius, identifier: "WarningRegion")
        if let circularRegion = self.circularRegion {
            circularRegion.notifyOnEntry = true
            circularRegion.notifyOnExit = true
            locationManager.startMonitoringForRegion(circularRegion)
        }
    }
    
    func stopTracking() {
        locationManager.stopUpdatingLocation()
        if let r = circularRegion{
            locationManager.stopMonitoringForRegion(r)
        }
    }
}

extension RegionViewController: CLLocationManagerDelegate{
    
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("did enter")
        if region is CLCircularRegion {
            if UIApplication.sharedApplication().applicationState == .Active {
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                self.showTextOverlay("Entered")
            } else {
                let notification = UILocalNotification()
                notification.alertBody = "Entered"
                notification.soundName = UILocalNotificationDefaultSoundName
                UIApplication.sharedApplication().presentLocalNotificationNow(notification)
            }
        }
    }
    
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("did exit")
    }
    
    func locationManager(manager: CLLocationManager, didStartMonitoringForRegion region: CLRegion) {
        print("Start monitoring region \(region.identifier)")
    }
    
    func locationManager(manager: CLLocationManager, monitoringDidFailForRegion region: CLRegion?, withError error: NSError) {
        print(error)
    }

}

extension RegionViewController: MKMapViewDelegate{
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKCircleRenderer(overlay: overlay)
        renderer.fillColor = UIColor.flatYellowColor().colorWithAlphaComponent(0.5)
        renderer.strokeColor = UIColor.flatYellowColorDark()
        renderer.lineWidth = 2.0
        return renderer
    }
}
