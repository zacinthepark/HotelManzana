//
//  SelectRoomTypeTableViewController.swift
//  HotelManzana
//
//  Created by zac on 2021/11/04.
//

import UIKit

protocol SelectRoomTypeTableViewControllerDelegate {
    func didSelect(roomType: RoomType)
}

class SelectRoomTypeTableViewController: UITableViewController {
    
    var delegate: SelectRoomTypeTableViewControllerDelegate?
    //현재 선택된 roomType 저장용 프로퍼티
    var roomType: RoomType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return RoomType.all.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RoomTypeCell", for: indexPath)
        let roomType = RoomType.all[indexPath.row]
        
        cell.textLabel?.text = roomType.name
        cell.detailTextLabel?.text = "$\(roomType.price)"
        
        //roomType은 테이블뷰 셀 정보에 들어가는 room type, self.roomType은 didSelectRowAt에 의해 현재 저장된 var roomType
        //셀에 있는 roomType이 선택된 roomType(self.roomType)과 같다면 checkmark가 생기도록 함
        if roomType == self.roomType {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
       
        return cell
    }
    
    // Delegate Method
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // 선택된 셀의 room type을 roomType 프로퍼티에 저장
        roomType = RoomType.all[indexPath.row]
        // Delegate을 수행하고 있는 vc에 해당 room type임을 알려줌
        delegate?.didSelect(roomType: roomType!)
        tableView.reloadData()
    }
    
}
