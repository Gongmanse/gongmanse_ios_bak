#  


## 일정등록

### 시간 데이터 흐름
시작 라벨 선택 시 날짜 선택하는 BottomPopup Present 시킴
날짜 선택하면 시간 선택하는 BottomPopup, String? 변수에 데이터 넘김
시간 선택하고 확인 누르면 Delegate 패턴으로 
StartTimePickerViewController -> StartLabelPickerViewController -> ScheduleAddViewController 
두 번의 Delegate 호출로 데이터 넘김

