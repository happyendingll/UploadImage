//
//  ViewController.m
//  多选图片
//
//  Created by holier_zyq on 2016/10/18.
//  Copyright © 2016年 holier_zyq. All rights reserved.
//

#import "ViewController.h"
#import "TZImagePickerController.h"
#import "CollectionViewCell.h"

#define Kwidth [UIScreen mainScreen].bounds.size.width
#define Kheight [UIScreen mainScreen].bounds.size.height
@interface ViewController ()<TZImagePickerControllerDelegate,UICollectionViewDelegate,UICollectionViewDataSource>{
    CGFloat _itemWH;
    CGFloat _margin;
}
@property (nonatomic ,strong) UICollectionView *collectionView;
@property (nonatomic ,strong) NSMutableArray *photosArray;
@property (nonatomic ,strong) NSMutableArray *assestArray;
@property BOOL isSelectOriginalPhoto;

@end

@implementation ViewController

- (NSMutableArray *)photosArray{
    if (!_photosArray) {
        self.photosArray = [NSMutableArray array];
    }
    return _photosArray;
}

- (NSMutableArray *)assestArray{
    if (!_assestArray) {
        self.assestArray = [NSMutableArray array];
    }
    return _assestArray;
}

-(UICollectionView *)collectionView{
    if (!_collectionView) {
        //_margin = 4;
        //_itemWH = (self.view.bounds.size.width - 2 * _margin - 4) / 3 - _margin;
        UICollectionViewFlowLayout *flowLayOut = [[UICollectionViewFlowLayout alloc] init];
        flowLayOut.itemSize = CGSizeMake((Kwidth - 50)/ 4, (Kwidth - 50)/ 4);
        //设置四个边缘的空隔距离
        flowLayOut.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 100, Kwidth, 300) collectionViewLayout:flowLayOut];
        
        
        _collectionView.backgroundColor = [UIColor yellowColor];
        //可以不设置滚动范围，flowlayout已经就有自动判别滚动了，我是这么认为的
        //_collectionView.contentSize = CGSizeMake(375*2, 600);
        
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        //        self.collectionView.scrollEnabled = NO;
    }
    return _collectionView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //给collectionView注册cell单元
    [self.collectionView registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    [self.view addSubview:self.collectionView];
   
    
}

- (void)checkLocalPhoto{
    //设置最大的可以选取的图片
    TZImagePickerController *imagePicker = [[TZImagePickerController alloc] initWithMaxImagesCount:30 delegate:self];
    //设置是否按照添加时间排序 NO:最新的图片放前面 YES:最新的图片放后面
    [imagePicker setSortAscendingByModificationDate:NO];
    // 如果isSelectOriginalPhoto为YES，表明用户选择了原图
    imagePicker.isSelectOriginalPhoto = _isSelectOriginalPhoto;
    //存放需要预览的图片，即以选中的图片集
    imagePicker.selectedAssets = _assestArray;
    //设置是否允许选择视频
    //imagePicker.allowPickingVideo = NO;
    imagePicker.allowPickingVideo = YES;
    [self presentViewController:imagePicker animated:YES completion:nil];
    
}

//点击图片选择器中的down（完成）按钮后要触发的方法
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto{
    self.photosArray = [NSMutableArray arrayWithArray:photos];
    self.assestArray = [NSMutableArray arrayWithArray:assets];
    _isSelectOriginalPhoto = isSelectOriginalPhoto;
    [_collectionView reloadData];
}



//设置collectionView原本代理方法中的点击item触发的方法
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    //如果点击了‘+’号item,则触发进入图片选择器的方法
    if (indexPath.row == _photosArray.count) {
        [self checkLocalPhoto];
    }
    //如果点击了图片item则进入图片预览视图
    else{
        TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithSelectedAssets:_assestArray selectedPhotos:_photosArray index:indexPath.row];
        //设置预览视图的图片是否原图，从初次图片选择器中获得
        imagePickerVc.isSelectOriginalPhoto = _isSelectOriginalPhoto;
        //点击了预览图片控制器的（完成）按钮后需要做的方法 此处用的是block回调方法
        [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
            _photosArray = [NSMutableArray arrayWithArray:photos];
            _assestArray = [NSMutableArray arrayWithArray:assets];
            _isSelectOriginalPhoto = isSelectOriginalPhoto;
            //_collectionView重新载入数据
            [_collectionView reloadData];
            //可以不设置滚动范围，flowlayout已经就有自动判别滚动了，我是这么认为的
            //_collectionView.contentSize = CGSizeMake(0, ((_photosArray.count + 2) / 3 ) * (_margin + _itemWH));
        }];
        [self presentViewController:imagePickerVc animated:YES completion:nil];
    }
}
//设置collectionView的item个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _photosArray.count+1;
}
//设置collectionView的内容填充
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    //如果是‘+’号item则填充图片
    if (indexPath.row == _photosArray.count) {
        cell.imagev.image = [UIImage imageNamed:@"AlbumAddBtn@2x"];
//        cell.imagev.backgroundColor = [UIColor redColor];
        cell.deleteButton.hidden = YES;
        
    }
    //如果是图片item则填充从图片选择器选择出来的图片集
    else{
        cell.imagev.image = _photosArray[indexPath.row];
        //把可以删除的按钮显示出来
        cell.deleteButton.hidden = NO;
    }
    
    //设置cell的deleteButton的tag属性
    cell.deleteButton.tag = 100 + indexPath.row;
    //给cell的deleteButton添加删除方法
    [cell.deleteButton addTarget:self action:@selector(deletePhotos:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
    
}
//点击deleteButton的删除方法
- (void)deletePhotos:(UIButton *)sender{
    [_photosArray removeObjectAtIndex:sender.tag - 100];
    [_assestArray removeObjectAtIndex:sender.tag - 100];
    //删除某一个item的block回调方法，支持多种操作multiple insert/delete/reload
    [_collectionView performBatchUpdates:^{
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:sender.tag-100 inSection:0];
        [_collectionView deleteItemsAtIndexPaths:@[indexPath]];
    } completion:^(BOOL finished) {
        //删除成功后重新载入数据
        [_collectionView reloadData];
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
