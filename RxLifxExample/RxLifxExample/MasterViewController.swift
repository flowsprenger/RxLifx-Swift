/*

Copyright 2017 Florian Sprenger

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit
persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the
Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

*/

import UIKit
import CoreData
import RxLifxApi
import RxLifx

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var detailViewController: DetailViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil

    let lightService:LightService = LightService(lightsChangeDispatcher: LightsChangeNotificationDispatcher(), transportGenerator: UdpTransport.self, extensionFactories: [LightsGroupLocationService.self, LightTileService.self])
    var lightsGroupLocationService: LightsGroupLocationService?
    var tileService: LightTileService?
    var lights:[Light] = []

    required init?(coder aDecoder: NSCoder) {
        lightsGroupLocationService = lightService.extensionOf()
        tileService = lightService.extensionOf()
        super.init(coder: aDecoder)
        lightsGroupLocationService?.setListener(groupLocationChangeDispatcher: LightsGroupLocationChangeNotificationDispatcher())
        tileService?.setListener(listener: TileChangeDispatcher())
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = self.editButtonItem

        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }

        lightService.start()

        NotificationCenter.default.addObserver(self, selector: #selector(lightUpdated), name: LightsChangeNotificationDispatcher.LightChangedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(lightAdded), name: LightsChangeNotificationDispatcher.LightAddedNotification, object: nil)
    }

    @objc func lightAdded(notification: Notification){
        if let light = notification.object as? Light {
            lights.append(light)
            tableView.reloadData()
        }
    }

    @objc func lightUpdated() {
        tableView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
            let light = lights[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = light
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lights.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        self.configureCell(cell, withLight: lights[indexPath.row])
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    func configureCell(_ cell: UITableViewCell, withLight light: Light) {
        cell.textLabel!.text = light.label.value ?? light.id
        
        if let cgColor = light.color.value?.toCGColor() {
            cell.backgroundColor = UIColor(cgColor:cgColor)
        }
    }

}

