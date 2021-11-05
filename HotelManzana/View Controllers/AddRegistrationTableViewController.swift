//
//  AddRegistrationTableViewController.swift
//  HotelManzana
//
//  Created by zac on 2021/11/03.
//

import UIKit

class AddRegistrationTableViewController: UITableViewController, SelectRoomTypeTableViewControllerDelegate {
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var checkInDateLabel: UILabel!
    @IBOutlet weak var checkOutDateLabel: UILabel!
    @IBOutlet weak var checkInDatePicker: UIDatePicker!
    @IBOutlet weak var checkOutDatePicker: UIDatePicker!
    
    @IBOutlet weak var numberOfAdultsLabel: UILabel!
    @IBOutlet weak var numberOfAdultsStepper: UIStepper!
    @IBOutlet weak var numberOfChildrenLabel: UILabel!
    @IBOutlet weak var numberOfChildrenStepper: UIStepper!
    
    @IBOutlet weak var wifiSwitch: UISwitch!
    
    @IBOutlet weak var roomTypeLabel: UILabel!
    
    //Property to hold the selected room type
    var roomType: RoomType?
    
    //이 vc에서 취합한 데이터를 바탕으로 빠르게 Registration 객체 생성
    var registration: Registration? {
        guard let roomType = roomType else {return nil}
        
        let firstName = firstNameTextField.text ?? ""
        let lastName = lastNameTextField.text ?? ""
        let email = emailTextField.text ?? ""
        let checkInDate = checkInDatePicker.date
        let checkOutDate = checkOutDatePicker.date
        let numberOfAdults = Int(numberOfAdultsStepper.value)
        let numberOfChildren = Int(numberOfChildrenStepper.value)
        let hasWifi = wifiSwitch.isOn
        
        return Registration(firstName: firstName, lastName: lastName, emailAddress: email, checkInDate: checkInDate, checkOutDate: checkOutDate, numberOfAdults: numberOfAdults, numberOfChildren: numberOfChildren, roomType: roomType, wifi: hasWifi)
    }
    
    let checkInDatePickerCellIndexPath = IndexPath(row: 1, section: 1)
    let checkOutDatePickerCellIndexPath = IndexPath(row: 3, section: 1)
    
    let checkInDateLabelCellIndexPath = IndexPath(row: 0, section: 1)
    let checkOutDateLabelCellIndexPath = IndexPath(row: 2, section: 1)
    
    var isCheckInDatePickerShown: Bool = false {
        didSet {
            checkInDatePicker.isHidden = !isCheckInDatePickerShown
        }
    }
    var isCheckOutDatePickerShown: Bool = false {
        didSet {
            checkOutDatePicker.isHidden = !isCheckOutDatePickerShown
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Check-In Date는 '현 시점'으로 고정이므로 viewDidLoad에서 설정
        let midnightToday = Calendar.current.startOfDay(for: Date())
        checkInDatePicker.minimumDate = midnightToday
        checkInDatePicker.date = midnightToday
        
        //Update Views
        updateDateViews()
        updateNumberOfGuests()
        updateRoomType()
    }
    
    //Adjust cell heights
    //Date Picker를 보여주는 cell이 가질 height값을 상황별로 정리
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath {
        case checkInDatePickerCellIndexPath:
            if isCheckInDatePickerShown {
                return 217.0
            } else {
                return 0.0
            }
        case checkOutDatePickerCellIndexPath:
            if isCheckOutDatePickerShown {
                return 217.0
            } else {
                return 0.0
            }
        default:
            return 44.0
        }
    }
    
    //Show or hide date pickers
    //Date Label을 선택했을 때 Date Picker가 어떻게 변할지를 상황별로 정리
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //어떠한 cell을 select한 이후 회색 highlight 상태를 제거해줌
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath {
        //만약 선택한 셀이 checkInDateLabel이라면 -> 1)checkInDatePicker가 열려있다면 닫아줘 2)checkOutDatePicker만 열려있다면 그거 닫고, checkInDatePicker를 열어줘 3)아무 DatePicker도 안열려있다면 checkInDatePicker를 열어줘
        case checkInDateLabelCellIndexPath:
            if isCheckInDatePickerShown {
                isCheckInDatePickerShown = false
            } else if isCheckOutDatePickerShown {
                isCheckOutDatePickerShown = false
                isCheckInDatePickerShown = true
            } else {
                isCheckInDatePickerShown = true
            }
            
            //Update the tableView with a pair of beginUpdates and endUpdates calls. These calls tell the tableView to requery its attributes - including cell height
            tableView.beginUpdates()
            tableView.endUpdates()
            
        //만약 선택한 셀이 checkOutDateLabel이라면 -> 상기와 동일 논리
        case checkOutDateLabelCellIndexPath:
            if isCheckOutDatePickerShown {
                isCheckOutDatePickerShown = false
            } else if isCheckInDatePickerShown {
                isCheckInDatePickerShown = false
                isCheckOutDatePickerShown = true
            } else {
                isCheckOutDatePickerShown = true
            }
            
            tableView.beginUpdates()
            tableView.endUpdates()
            
        //선택한 셀이 DateLabel이 아니라면 아무것도 안할거야
        default:
            break
        }
    }
    
    func didSelect(roomType: RoomType) {
        self.roomType = roomType
        updateRoomType()
    }
    
    /*  AddRegistrationVC -> SelectRoomTypeVC
        1)SelectRoomTypeTableVC의 delegate을 현재 vc로 채택
        2)그리고 만약 현재 vc에 저장되어있는 room type이 있다면(즉, 이미 SelectRoomTypeVC에서 고른 적이 있다면), 해당 room type도 넘겨줌
        SelectRoomTypeVC -> AddRegistrationVC
        1)SelectRoomTypeVC에 있는 didSelectRowAt에 구현되어 있는 delegate?.didSelect(roomType: roomType!)을 통해서 다시 선택된 room type을 AddRegistrationVC로 넘겨줌
        2)AddRegistrationVC에 구현되어 있는 didSelect(roomType:)을 통해서 다시 roomType 프로퍼티에 새로운 room type이 저장됨
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SelectRoomType" {
            let destinationViewController = segue.destination as? SelectRoomTypeTableViewController
            destinationViewController?.delegate = self
            destinationViewController?.roomType = roomType
        }
    }
    
}

extension AddRegistrationTableViewController {
    func updateDateViews() {
        //Check-In Date가 바뀔 때마다 Check-out Date의 범위 재설정
        checkOutDatePicker.minimumDate = checkInDatePicker.date.addingTimeInterval(86400)
        
        //Date -> String
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        
        //위 정보를 바탕으로 선택 날짜 표시
        checkInDateLabel.text = dateFormatter.string(from: checkInDatePicker.date)
        checkOutDateLabel.text = dateFormatter.string(from: checkOutDatePicker.date)
    }
    
    func updateNumberOfGuests() {
        numberOfAdultsLabel.text = "\(Int(numberOfAdultsStepper.value))"
        numberOfChildrenLabel.text = "\(Int(numberOfChildrenStepper.value))"
    }
    
    func updateRoomType() {
        if let roomType = roomType {
            roomTypeLabel.text = roomType.name
        } else {
            roomTypeLabel.text = "Not set"
        }
    }
}

extension AddRegistrationTableViewController {
    
    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
        updateDateViews()
    }
    
    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        updateNumberOfGuests()
    }
    
    @IBAction func wifiSwitchChanged(_ sender: UISwitch) {
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
