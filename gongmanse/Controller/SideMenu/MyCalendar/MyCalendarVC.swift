import UIKit
import FSCalendar

class MyCalendarVC: UIViewController {

    // MARK: - Properties
    
    private let height = UIScreen.main.bounds.height
    
    var tableConstrant: NSLayoutConstraint?
    
    private var isBottomTableHeight: Bool = false {
        didSet {
            tableConstrant?.constant = isBottomTableHeight ? -height / 3 + 30 : 0
            
            UIView.animate(withDuration: 0.3) {
                self.tableView.topAnchor.constraint(equalTo: self.view.bottomAnchor,
                                                    constant: self.tableConstrant!.constant).isActive = true
                self.view.layoutIfNeeded()
            }
        }
    }
    
    private var calendarView: FSCalendar = {
        let view = FSCalendar()
        view.appearance.headerDateFormat = "YYYY년 M월"                              // 헤더 ( 년 월 )
        view.appearance.headerTitleColor = .black                                   // 해더 ( 년 월 ) 폰트 색
        view.appearance.headerTitleFont = .appBoldFontWith(size: 26)                // 헤더 ( 년 월 ) 폰트 사이즈
        view.appearance.titleDefaultColor = .rgb(red: 112, green: 112, blue: 112)   // 일정라벨 색 변경
        view.appearance.titleFont = .appBoldFontWith(size: 20)                      // 일정라벨 ( 1, 2, 3 -- ) 폰트 변경
        view.appearance.headerMinimumDissolvedAlpha = 0
        
        // 현재달에서 다음달, 이전달 날짜 나오는 상태 변경
        view.placeholderType = .none
        
        view.locale = Locale(identifier: "ko-KR")
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
        
        view.appearance.eventDefaultColor = .mainOrange
        return view
    }()
    
    private let formatter: DateFormatter = {
        let date = DateFormatter()
        date.dateFormat = "yyyy-MM"
        date.locale = Locale(identifier: "ko_KR")
        
        return date
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
    
    let previousButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "scheduleLeft"), for: .normal)
        return button
    }()
    
    let nextButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "scheduleRight"), for: .normal)
        return button
    }()
    
    // 테이블 헤더 프로퍼티
    lazy var headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 40))
    
    let calendarImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.image = UIImage(named: "schedule")
        return image
    }()
    
    let headerTitlte: UILabel = {
        let label = UILabel()
        label.text = "일정"
        label.font = .appBoldFontWith(size: 14)
        label.textAlignment = .left
        label.setContentHuggingPriority(.defaultLow - 5, for: .horizontal)
        return label
    }()
    
    let dismissButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "close24Px"), for: .normal)
        return button
    }()
    
    lazy var headerStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [calendarImage, headerTitlte, dismissButton])
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fillProportionally
        stack.spacing = 2
        return stack
    }()
    //
    
    var currentPage: Date?
    var myCalendarVM: MyCalendarViewModel? = MyCalendarViewModel()
    
    // MARK: - LifeCycle
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        view.endEditing(true)
        
        isBottomTableHeight = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationConfigure()
        configuration()
        constraints()
        
        floatingButton.addTarget(self, action: #selector(scheduleRegistration(_:)), for: .touchUpInside)
    
        
        let currentDate = formatter.string(from: Date())
        myCalendarVM?.requestMyCalendarApi(currentDate)
        
        previousButton.addTarget(self, action: #selector(tappedPrevBtn(_:)), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(tappedNextBtn(_:)), for: .touchUpInside)
        dismissButton.addTarget(self, action: #selector(dismissAction(_:)), for: .touchUpInside)
        
    }
    
    @objc func dismissAction(_ sender: UIButton) {
        tableConstrant?.constant = 0
    }
    
    @objc func scheduleRegistration(_ sender: UIButton) {

        let vc = ScheduleAddViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func tappedPrevBtn(_ sender: UIButton) {
        self.moveCurrentPage(moveUp: false)
    }
    
    @objc func tappedNextBtn(_ sender: UIButton) {
        self.moveCurrentPage(moveUp: true)
    }
    
}

// MARK: - BottomTableView

extension MyCalendarVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        headerView.backgroundColor = .rgb(red: 237, green: 237, blue: 237)
        
        return headerView
    }
    
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
    
    private func moveCurrentPage(moveUp: Bool) {
        
        var dateComponents = DateComponents()
        dateComponents.month = moveUp ? 1 : -1
        
        let calendarCurrent = Calendar.current
        currentPage = calendarCurrent.date(byAdding: dateComponents, to: currentPage ?? Date())
        self.calendarView.setCurrentPage(currentPage!, animated: true)
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        isBottomTableHeight = true
        
        tableView.reloadData()
    }
    
    // 페이지 넘길 때 한번 호출
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        
        let currentDate = formatter.string(from: calendar.currentPage)
        myCalendarVM?.requestMyCalendarApi(currentDate)
    
        
    }
    
    // 이벤트 개수 표현하는 메소드
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        
        guard let dateList = myCalendarVM?.dateList else { return 0 }
        
        if dateList.contains(date) {
            return 1
        }
        return 0
    }
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
        
        myCalendarVM?.calendarDelegate = self
        view.addSubview(calendarView)
        view.addSubview(previousButton)
        view.addSubview(nextButton)
        view.addSubview(floatingButton)
        view.addSubview(tableView)
        

        headerView.addSubview(headerStackView)
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
        tableConstrant = tableView.topAnchor.constraint(equalTo: view.bottomAnchor)
        tableConstrant?.isActive = true

        
        previousButton.translatesAutoresizingMaskIntoConstraints = false
        previousButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        previousButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        
        
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        
        // TableView Section
        headerStackView.translatesAutoresizingMaskIntoConstraints = false
        headerStackView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
        headerStackView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20).isActive = true
        headerStackView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20).isActive = true
        
        calendarImage.translatesAutoresizingMaskIntoConstraints = false
        calendarImage.widthAnchor.constraint(equalToConstant: 24).isActive = true
        calendarImage.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        dismissButton.widthAnchor.constraint(equalToConstant: 24).isActive = true
        dismissButton.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
    }
}

extension MyCalendarVC: CollectionReloadData {
    func reloadCollection() {
        DispatchQueue.main.async {
            self.calendarView.reloadData()
        }
    }
}
