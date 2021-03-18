#  "검색" 화면
by WooSung

## To-Do list 

1. API 연동을 통한 데이터 수신
    - 최초 수신 : SearchVC.swift (네트워크 통신 혹은 MainTabBarControler 에서 값을 받아올 예정)
    - 검색 시, SearchVC -> SearchAfterVC 로 데이터 전달
    
2. 중복 검색어 처리 로직
    -  검색 Keyword를 모두 SearhVC로 전송하여 RecentKeywordVC(최근검색어) 에 로그 남김
    -> API 연동 시, 자동으로 중복된 데이터 필터링 되는지 여부에 따라서 **removeDuplicate(_:)** 데이터 사용여부 결정
    
    
## Search 파일 구조

### SearchVC : 메인 탭바에서 클릭 시 제일먼저 나타나는 Controller
하위 Controller
-   Search_before 폴더 : PopularKeywordVC(인기검색어 탭), RecentKeywordVC(최근 검색어 탭)

### SearchAfterVC : SearchVC의 UISearchBar 검색 or 인기검색어 클릭 으로 검색 시, 나타날 검색결과 Controller
하위 Controller
 - Search_After 폴더 : SearchAferVC(검색결과화면, 가장 상위단위 controller), SearchVideoVC(동영상 백과), SearchConsultVC(전문가 상담), SearchNoteVC(노트 검색)
 
 ### 화면 순서
 SearchVC의 UISearchBar에서 검색 -> SearchAfterVC 화면전환 -> 하위탭 구성 (SearchVideoVC, SearchConsultVc, SearchNoteVC) -> 뒤로가기 버튼 클릭 -> SearchVC 복귀 ( 이 때, 인기검색어에 있었다면 인기검색어로 최근검색어에서 이동했다면 최근검색어로 이동)
 
    




