//
//  HHLoopingPictures.swift
//  LoopingPictures
//
//  Created by Sherlock on 2019/5/15.
//  Copyright © 2019 daHuiGe. All rights reserved.
//

import UIKit

class CustomCell: UICollectionViewCell {
    
    var imgView: UIImageView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func initView(frame: CGRect){
        imgView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: frame.width, height: frame.height))
        imgView?.contentMode = .scaleAspectFill
        self.addSubview(imgView!)
    }
}

protocol PicturesClickDelegate: NSObjectProtocol {
    func clickAtIndex(index: Int)
}

class HHLoopingPictures: NSObject {
    
    private var timer: Timer?
    private let cellIDF = "picturesLoopCell"
    private let pageCount = 1001    //定义在500组到501直接自动循环
    private var sWidth: CGFloat = 0
    private var sHeight: CGFloat = 0
    private var timeInterval: Double = 3.0
    private var imgSource: [UIImage] = []
    weak var delegate: PicturesClickDelegate?
    
    init(superView: UIView, frame: CGRect, time: Double, images: [UIImage]) {
        
        //初始化变量
        sWidth = frame.width
        sHeight = frame.height
        timeInterval = time
        imgSource = images

        super.init()
        
        //加载View, 并初始化定时器
        setupView(superView: superView, frame: frame)
        setupTimer()
    }
    
    deinit {
        print("HHLoopingPictures deinit")
    }
    
    // 根据需要动态改变轮播图frame
    func resizeViewFrame(frame: CGRect) {
        sWidth = frame.width
        sHeight = frame.height
        collectionView.frame = CGRect.init(x: frame.minX, y: frame.minY, width: frame.width, height: frame.height)
        pageControl.frame = CGRect.init(x: frame.minX, y: frame.minY+frame.height-20, width: frame.width, height: 20)
    }
    
    //开启定时器
    func setupTimer() {
        if (timer == nil) {
            removeTimer()
        }
        let tr = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(pageDidChanged), userInfo: nil, repeats: true)
        RunLoop.main.add(tr, forMode: .common)
        timer = tr
    }
    
    //关闭定时器
    func removeTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func setupView(superView: UIView, frame: CGRect) {
        superView.addSubview(collectionView)
        superView.addSubview(pageControl)
        collectionView.frame = CGRect.init(x: frame.minX, y: frame.minY, width: frame.width, height: frame.height)
        pageControl.frame = CGRect.init(x: frame.minX, y: frame.minY+frame.height-20, width: frame.width, height: 20)
        collectionView.scrollToItem(at: IndexPath.init(item: imgSource.count*((pageCount-1)/2), section: 0), at: .left, animated: false)
    }
    
    @objc func pageDidChanged() {
        let startIndex = imgSource.count * ((pageCount - 1) / 2)    //真正自动循环的一组图片的起始index
        let endIndex = startIndex + imgSource.count     //真正自动循环的一组图片的结束index
        let currentIndexPath = collectionView.indexPathsForVisibleItems.last ?? IndexPath.init(item: startIndex, section: 0)
        let nextItem = currentIndexPath.item + 1;
        if nextItem >= startIndex && nextItem < endIndex {
            // 真正原理: 始终循环中间的一组图片
            let nextIndexPath = IndexPath.init(item: nextItem, section: currentIndexPath.section)
            collectionView.scrollToItem(at: nextIndexPath, at: .left, animated: true)
        } else {
            // 不在最中间的一组图片时(即手动拖拽到其他位置后), 在定时器重启的时候, 重新恢复到中间循环
            let matchIndex = (currentIndexPath.item % imgSource.count) + startIndex
            let matchIndexPath = IndexPath.init(item: matchIndex, section: currentIndexPath.section)
            collectionView.scrollToItem(at: matchIndexPath, at: .left, animated: false)
            let nextIndexPath = IndexPath.init(item: matchIndex+1, section: currentIndexPath.section)
            collectionView.scrollToItem(at: nextIndexPath, at: .left, animated: true)
        }
    }

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout.init()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let cv = UICollectionView.init(frame: .zero, collectionViewLayout: layout)
        cv.register(CustomCell.self, forCellWithReuseIdentifier: cellIDF)
        cv.delegate = self
        cv.dataSource = self
        cv.isPagingEnabled = true
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        return cv
    }()
    
    private lazy var pageControl: UIPageControl = {
        let pc = UIPageControl.init(frame: .zero)
        pc.numberOfPages = imgSource.count
        pc.currentPage = 0
        return pc
    }()
    
}

extension HHLoopingPictures: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.clickAtIndex(index: indexPath.row % imgSource.count)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imgSource.count * pageCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIDF, for: indexPath) as! CustomCell
        cell.imgView?.image = imgSource[indexPath.row % imgSource.count]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: sWidth, height: sHeight)
    }
    
}

extension HHLoopingPictures: UIScrollViewDelegate {
    
    // 当用户开始拖拽的时候就调用
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        timer?.fireDate = Date.distantFuture
    }
    // 当用户停止拖拽的时候调用
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        timer?.fireDate = Date.init(timeInterval: timeInterval/2, since: Date())
    }
    // 设置页码
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x / sWidth + 0.5) % imgSource.count
        pageControl.currentPage = page
    }
    
}
