package com.gongmanse.app.utils

import androidx.recyclerview.widget.GridLayoutManager
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import androidx.recyclerview.widget.StaggeredGridLayoutManager

abstract class EndlessRVScrollListener: RecyclerView.OnScrollListener {

    // 시작 오프셋 인덱스 색인을 설정
    private val startingOffsetIndex = 0

    // 추가 로드 전, 현재 스크롤 위치 아래에 있어야하는 최소 항목 수
    private var visibleThresholds = 5

    // 로드 한 데이터의 현재 오프셋 인덱스
    private var currentOffset = 0

    // 마지막로드 후 데이터 세트의 총 항목 수
    private var previousTotalItemCount = 0

    // 로드 할 마지막 데이터 세트를 기다리고있는 경우 true
    private var loading = true

    var mLayoutManager: RecyclerView.LayoutManager

    constructor(layoutManager: LinearLayoutManager) {
        mLayoutManager = layoutManager
    }

    constructor(layoutManager: GridLayoutManager) {
        mLayoutManager = layoutManager
        visibleThresholds *= layoutManager.spanCount
    }

    constructor(layoutManager: StaggeredGridLayoutManager) {
        mLayoutManager = layoutManager
        visibleThresholds *= layoutManager.spanCount
    }

    private fun getLastVisibleItem(lastVisibleItemPositions: IntArray): Int {
        var maxSize = 0
        for (i in lastVisibleItemPositions) {
            if (i == 0) {
                maxSize = lastVisibleItemPositions[i]
            } else if (lastVisibleItemPositions[i] > maxSize) {
                maxSize = lastVisibleItemPositions[i]
            }
        }
        return maxSize
    }

    // 이것은 스크롤하는 동안 초당 여러 번 발생하므로 여기에 배치하는 코드에주의하십시오.
    // 더 많은 데이터를 로드해야하는지 확인하는데 도움이 되는 몇 가지 유용한 매개 변수가 제공되지만,
    // 먼저 이전 로드가 완료 될 때까지 기다리고 있는지 확인합니다.
    override fun onScrolled(view: RecyclerView, dx: Int, dy: Int) {
        var lastVisibleItemPosition = 0
        val totalItemCount = mLayoutManager.itemCount
        when (mLayoutManager) {
            is StaggeredGridLayoutManager -> {
                val lastVisibleItemPositions = (mLayoutManager as StaggeredGridLayoutManager).findLastVisibleItemPositions(null)
                // 목록 내에서 최대 요소 가져 오기
                lastVisibleItemPosition = getLastVisibleItem(lastVisibleItemPositions)
            }
            is GridLayoutManager -> {
                lastVisibleItemPosition = (mLayoutManager as GridLayoutManager).findLastVisibleItemPosition()
            }
            is LinearLayoutManager -> {
                lastVisibleItemPosition = (mLayoutManager as LinearLayoutManager).findLastVisibleItemPosition()
            }
        }

        // 총 항목 수가 0이고 이전 항목이 아닌 경우 목록이 무효화되고,
        // 초기 상태로 다시 재설정되어야한다고 가정합니다.
        if (totalItemCount < previousTotalItemCount) {
            currentOffset = startingOffsetIndex
            previousTotalItemCount = totalItemCount
            if (totalItemCount == 0) {
                loading = true
            }
        }
        // 여전히로드 중이면 데이터 세트 개수가 변경되었는지 확인하고,
        // 그렇다면 로드가 완료되었다고 판단하고 현재 페이지 번호와 총 항목 개수를 업데이트합니다.
        if (loading && totalItemCount > previousTotalItemCount) {
            loading = false
            previousTotalItemCount = totalItemCount
        }

        // 현재로드되지 않는 경우 표시되는 임계 값에 도달했는지 확인하고 더 많은 데이터를 다시로드해야합니다.
        // 더 많은 데이터를 다시로드해야하는 경우 onLoadMore()를 실행하여 데이터를 가져옵니다.
        // 임계 값은 너무 많은 총 열 수를 반영해야합니다.
        if (!loading && lastVisibleItemPosition + visibleThresholds > totalItemCount) {
            currentOffset++
            onLoadMore(currentOffset, totalItemCount, view)
            loading = true
        }
    }

    // 새 검색을 수행 할 때마다이 메서드를 호출합니다.
    fun resetState() {
        currentOffset = startingOffsetIndex
        previousTotalItemCount = 0
        loading = true
    }

    // 실제로 페이지를 기반으로 더 많은 데이터를로드하는 프로세스를 정의합니다.
    abstract fun onLoadMore(offset: Int, totalItemsCount: Int, view: RecyclerView?)

}