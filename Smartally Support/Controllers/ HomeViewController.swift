//
//  HomeViewController.swift
//  Smartally Support
//
//  Created by Muqtadir Ahmed on 23/05/17.
//  Copyright © 2017 Bitjini. All rights reserved.
//

import Koloda
import UIKit
import FirebaseMessaging

protocol NotificationDelegate {
   func getJobs()
}

var delegate : NotificationDelegate?

var didReceiveNotification = false

class HomeViewController: BaseViewController, JobViewDelegate , NotificationDelegate {
    
    // @IBOutlets.
   // @IBOutlet weak var viewKoloda: KolodaView!
   // @IBOutlet weak var tableViewJob: UITableView!
    @IBOutlet weak var collectionViewJob: UICollectionView!
    // Parameters.
    var didLoad: Bool = false
    
    // Class Instances.
    var viewJob: JobView {
        let view = Bundle.main.loadNibNamed("JobView", owner: self, options: nil)?.first as! JobView
        view.delegate = self
        return view
    }
    
    var job: GetJob {
        let job = GetJob()
        job.delegate = self
        return job
    }
    
    var updateJob: UpdateJob {
        let update = UpdateJob()
        update.delegate = self
        return update
    }

    // Lifecycle.
    override func viewDidLoad() { super.viewDidLoad(); onViewDidLoad() }
    override func viewDidAppear(_ animated: Bool) { super.viewDidAppear(animated); onViewDidAppear() }
    override func viewDidLayoutSubviews() { super.viewDidLayoutSubviews() ; onViewDidLayoutSubviews() }
    
    func onViewDidLoad() {
        // Koloda preferences.
        //viewKoloda.dataSource = self
        //viewKoloda.delegate = self
        delegate = self
        // Navigation Bar preferences.
        let reloadButton = UIBarButtonItem(title: "More Jobs", style: .plain, target: self, action: #selector(getJobs))
        navigationItem.rightBarButtonItem = reloadButton
        
        //tableViewJob.register(UINib(nibName: "HomeTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "HomeTableViewCell")
        collectionViewJob.register(UINib(nibName: "HomeCollectionViewCell",bundle:Bundle.main), forCellWithReuseIdentifier: "HomeCollectionViewCell")
       // map()
        
    }
    
    func map() {
        let array = [1,2,3,4,5]
        
        let array1 = array.map { (value:Int) -> Int in
            return value * 2
        }
        print(array1)
        
        let array2 = array.map{value in value * 2}
        print(array2)
        
        let array3 = array.map{$0 * 2}
        print(array3)
    }
   
    func onViewDidLayoutSubviews() {
        var insets = self.collectionViewJob.contentInset
        var value : CGFloat = 10.0
        insets.left = value
        insets.right = value
      if Job.jobs.isEmpty {
           value = (self.view.frame.size.width - (self.collectionViewJob.collectionViewLayout as! UICollectionViewFlowLayout).itemSize.width) * 0.25
        //insets.left = 30
     //   insets.right = 30
       }
        
        self.collectionViewJob.contentInset = insets
        self.collectionViewJob.decelerationRate = UIScrollViewDecelerationRateFast;
    }
    
    func onViewDidAppear() {
        
        if didLoad { reload(); return }
        didLoad = true
        
        getJobs()
    }
    
    func getJobs() {
        indicator.start(onView: view)
        job.getJobs()
    }
    
    func updateJob(atIndex index: Int) {
        swiped(jobAtIndex: index)
    }
}

extension HomeViewController: GetJobDelegate {
    
    func reload() {
        indicator.stop()
       // viewKoloda.resetCurrentCardIndex()
       // tableViewJob.reloadData()
        collectionViewJob.reloadData()
    }
    
    func failed(withError error: String) {
        indicator.stop()
        dropBanner(withString: error)
        _ = (error == "Job already completed." || error == "Job not found.") ?
           getJobs() : reload()
           // viewKoloda.revertAction()
    }
}

extension HomeViewController : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Job.jobs.isEmpty ? 1 : Job.jobs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if Job.jobs.isEmpty {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NoDataCell", for: indexPath)
            
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCollectionViewCell", for: indexPath) as! HomeCollectionViewCell
        cell.buttonUpdate.tag = indexPath.row
        cell.tag = indexPath.row
        cell.delegate = self
        cell.set()
        
        return cell
    }
    
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if Job.jobs.isEmpty { return CGSize(width: collectionView.frame.size.width , height: collectionView.frame.size.height/1.25) }
        return CGSize(width: collectionView.frame.size.width, height: 425) //405
    }
}

// Swiped Right Update.
extension HomeViewController: UpdateJobDelegate {
    
    func swiped(jobAtIndex index: Int) {
        guard Job.jobs.indices.contains(index) else { dropBanner(withString: "Invalid job."); return }
        do
        {
            try Validator.validate(job: Job.jobs[index])
            update(job: Job.jobs[index])
        }
        catch Validator.Err.name {
            dropBanner(withString: "Can't update job with blank merchant name.")
            // Bring back the table.
           // viewKoloda.revertAction()
        }
        catch Validator.Err.amount {
            dropBanner(withString: "Can't update job with blank amount.")
            // Bring back the table.
          //  viewKoloda.revertAction()
        }
        catch Validator.Err.date {
            dropBanner(withString: "Can't update job with blank date.")
            // Bring back the table.
         //   viewKoloda.revertAction()
        }
        catch {} // Nope, never ever!
    }
    
    func update(job: Job.Job) {
        indicator.start(onView: view)
        updateJob.updateJob(job: job)
    }
    
    func updated(jobWithID ID: String) {
        // Remove the updated job.
        Job.deleteJob(byID: ID)
        reload()
    }
}

// Delegate:
//extension HomeViewController: KolodaViewDelegate {
//
//    func koloda(_ koloda: KolodaView, shouldDragCardAt index: Int) -> Bool {
//        return !Job.jobs.isEmpty
//    }
//
//    func koloda(_ koloda: KolodaView, shouldSwipeCardAt index: Int, in direction: SwipeResultDirection) -> Bool {
//        return direction == .right || direction == .left
//    }
//
//    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
//        if direction == .right{ swiped(jobAtIndex: index) } else { swipedLeft(jobAtIndex: index) }
//    }
//
//    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
//        koloda.resetCurrentCardIndex()
//    }
//}


//// Swiped left.
//extension HomeViewController {
//
//    func swipedLeft(jobAtIndex index: Int) {
//        if index == Job.jobs.count { return }
//     //  let _ = viewKoloda.viewForCard(at: index + 1)
//
//    }
//}

// DataSource:
//extension HomeViewController: KolodaViewDataSource {
//
//    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
//        return Job.jobs.isEmpty ? 1 : Job.jobs.count
//    }
//
//    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
//        return .default
//    }
//
//    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
//        if Job.jobs.isEmpty {
//            let imageView = UIImageView(image: UIImage(named: "no_data"))
//            imageView.contentMode = .center
//            return imageView
//        }
//
//        let view = viewJob
//        view.tag = index; view.set()
//        return view
//    }
//
//    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
//        return nil
//    }
//}


