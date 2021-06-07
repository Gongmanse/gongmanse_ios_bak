import UIKit
import FSCalendar

class MyCalendarVC: UIViewController {

    // MARK: - Properties
    
    private let height = UIScreen.main.bounds.height
    
    private var calendarView: FSCalendar = {
        let view = FSCalendar()
        view.appearance.headerDateFormat = "YYYY년 M월"                              // 헤더 ( 년 월 )
        view.appearance.headerTitleColor = .black                                   // 해더 ( 년 월 ) 폰트 색
        view.appearance.headerTitleFont = .appBoldFontWith(size: 26)                // 헤더 ( 년 월 ) 폰트 사이즈
        view.appearance.titleDefaultColor = .rgb(red: 112, green: 112, blue: 112)   // 일정라벨 색 변경
        view.appearance.titleFont = .appBoldFontWith(size: 20)                      // 일정라벨 ( 1, 2, 3 -- ) 폰트 변경
        
        // 현재달에서 다음달, 이전달 날짜 나오는 상태 변경
        view.placeholderType = .none
        
        view.locale = Locale(identifier: "ko_KR")
        view.calendarWeekdayView.weekdayLabels[0].textColor = .rgb(red: 255, green: 0, blue: 35)    // 일 색 변경
        view.calendarWeekdayView.weekdayLabels[6].textColor = .rgb(red: 21, green: 176, blue: 172)  // 토 색 변경
        
        // 주간 라벨들 폰트 변경
        view.calendarWeekdayView.weekdayLabels[0].font = .appBoldFontWith(size: 18)
        view.calendarWeekdayView.weekdayLabels[1].font = .appBoldFontWith(size: 18)
        view.calendarWeekdayView.weekdayLabels[2].font = .appBoldFontWith(size: 18)
        view.calendarWeekdayView.weekdayLabels[3].font = .appBoldFontWith(size: 18)
        view.calendarWeekdayView.weekdayLabels[4].font = .appBoldFontWith(size: 18)
        view.calendarWeekdayView.weekdayLabels[5].font = .appBoldFontWith(size: 18)
        view.calendarWeekdayView.weekdayLabels[6].font = .appBoldFontWith(size: 18)
        
        return view
    }()
    
    let floatingButton: UIButton = {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 56, height: 56)
        button.setImage(UIImage(named: "floatingBtn"), for: .normal)
        return button
    }()
    
    let tableView: UITableView = {
        let table = UITableView()
        return table
    }()
    
    var myCalendarVM: MyCalendarViewModel? = MyCalendarViewModel()
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()


        navigationConfigure()
        configuration()
        constraints()
        
        floatingButton.addTarget(self, action: #selector(scheduleRegistration(_:)), for: .touchUpInside)
        
//        myCalendarVM?.myCalendarApi("2021-04")
    }
    
    @objc func scheduleRegistration(_ sender: UIButton) {
        let vc = ScheduleAddViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - BottomTableView

extension MyCalendarVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MyCalendarCell.identifier, for: indexPath) as? MyCalendarCell else { return UITableViewCell() }
        
        return cell
    }
}

// MARK: - Calendar

extension MyCalendarVC: FSCalendarDelegate, FSCalendarDataSource {
    
}

// MARK: - UI

extension MyCalendarVC {

    func navigationConfigure() {
        //네비게이션 바 타이틀 정하기
        self.navigationItem.title = "나의 일정"
        
        //네비게이션 바 뒤로가기 버튼 색상 바꾸기
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1)
        
        //네비게이션 바 뒤로가기 버튼 타이틀 없애기
        self.navigationController?.navigationBar.topItem?.title = ""
    }
    
    func configuration() {
        
        view.addSubview(calendarView)
        view.addSubview(floatingButton)
        view.addSubview(tableView)
        
        calendarView.delegate = self
        calendarView.dataSource = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MyCalendarCell.self, forCellReuseIdentifier: MyCalendarCell.identifier)
    }
    
    func constraints() {
        
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        calendarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        calendarView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        calendarView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        calendarView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -(height / 3)).isActive = true
        
        floatingButton.translatesAutoresizingMaskIntoConstraints = false
        floatingButton.bottomAnchor.constraint(equalTo: tableView.topAnchor, constant: -30).isActive = true
        floatingButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30).isActive = true
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.bottomAnchor, constant: -view.frame.size.height / 3).isActive = true
        
        
    }
}
