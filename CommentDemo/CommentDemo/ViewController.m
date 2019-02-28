//
//  ViewController.m
//  CommentDemo
//
//  Created by tanlu on 2019/1/9.
//  Copyright © 2019年 tanlu. All rights reserved.
//
#define  imageWidth 60
#define  betweenWidth 10.0
#define  width_20 20.0
#define num_280 280
#define SIZE [UIScreen mainScreen].bounds.size

#import "ViewController.h"
#import <YYText.h>
#import <IQKeyboardManager.h>
#import "TZImagePickerController.h"
#import "CustomYYImage.h"
#import <Masonry.h>
#import "UIColor+LCColor.h"
#import "ImageModel.h"
@interface ViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,TZImagePickerControllerDelegate,YYTextViewDelegate,ImageViewDataSource>
{
    NSMutableAttributedString *text;
    NSInteger keyBoardHeight;
    UIView *_toolView;
}
@property (strong, nonatomic) YYTextView *textView;
@property (nonatomic, assign) NSRange textViewRange;
@property(nonatomic,copy)NSString*tipStr;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"发布评论";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"提交" style:UIBarButtonItemStylePlain target:self action:@selector(clickRightBtn)];
    self.view.backgroundColor = [UIColor colorWithRed:232/255.0 green:234/255.0 blue:235/255.0 alpha:1];
    [self creatUI];
    // Do any additional setup after loading the view, typically from a nib.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.textView becomeFirstResponder];
}
-(void)creatUI
{
    self.textView = [[YYTextView alloc]init];
    self.textView.userInteractionEnabled = YES;
    self.textView.textVerticalAlignment = YYTextVerticalAlignmentTop;
    self.textView.attributedText = text;
    self.textView.font = [UIFont systemFontOfSize:16];
    self.textView.placeholderFont = [UIFont systemFontOfSize:16];
    self.textView.placeholderText = self.tipStr;
    self.textView.textContainerInset = UIEdgeInsetsMake(10, 0, 10, 0);
    [self.view addSubview:self.textView];
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(64);
        make.left.equalTo(self.view.mas_left).offset(15);
        make.right.equalTo(self.view.mas_right).offset(-15);
        make.bottom.equalTo(self.view.mas_bottom).offset(0);
    }];
    self.textView.delegate = self;
    //增加监听，当键盘出现或改变时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    //增加监听，当键退出时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    //键盘上方加三个按钮
    _toolView  = [[UIView alloc]init];
    _toolView.backgroundColor = [UIColor colorWithHexString:@"E1E1E1"];
    _toolView.frame = CGRectMake(0, SIZE.height - 40, SIZE.width, 40);
    [self.view addSubview:_toolView];
    UIView*lineView1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SIZE.width, 0.5)];
    lineView1.backgroundColor = [UIColor colorWithHexString:@"9B9B9B"];
    [_toolView addSubview:lineView1];
    
    UIButton *imageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [imageBtn setImage:[UIImage imageNamed:@"add_image"] forState:UIControlStateNormal];
    imageBtn.frame = CGRectMake(10, 0, 47, 40);
    [imageBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [imageBtn addTarget:self action:@selector(imageBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [_toolView addSubview:imageBtn];
    
    UIButton *cameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cameraBtn setImage:[UIImage imageNamed:@"add_camera"] forState:UIControlStateNormal];
    
    cameraBtn.frame = CGRectMake(64, 0, 47, 40);
    [cameraBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cameraBtn addTarget:self action:@selector(cameraBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [_toolView addSubview:cameraBtn];
    
    UIButton * finishButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [finishButton setTitleColor:[UIColor colorWithHexString:@"1ABF9A"] forState:UIControlStateNormal];
    finishButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [finishButton setTitle:@"完成" forState:UIControlStateNormal];
    finishButton.frame = CGRectMake(SIZE.width-50, 0, 47, 40);
    [finishButton addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    [_toolView addSubview:finishButton];
}
#pragma mark--点击提交按钮
-(void)clickRightBtn
{
    //获取f编辑内容
    NSMutableArray *postArray = [[self p_trimIsMove:NO] mutableCopy];
    for (int i = 0; i < postArray.count; i++) {
        if ([postArray[i] isKindOfClass:[ImageModel class]]) {
            ImageModel *model = postArray[i];
            NSString *imageStr = [NSString stringWithFormat:@"<img width=100%%  src=\"%@\" alt="" />",model.abbrUrl];
            //            NSString *imageStr = [NSString stringWithFormat:@"<img width=100% src="http://7xojj3.com1.z0.glb.clouddn.com/image/sharepic/c08b5835fe47bc9c307575a93057c47e.jpg" alt="2017-04-11 10:09:52:068">", full, abbr, title];
            postArray[i] = imageStr;
        }
    }
    NSMutableString *postString = [NSMutableString new];
    for (int i = 0; i < postArray.count; i++) {
        if (i == 0) [postString appendString:postArray[i]];
        else [postString appendFormat:@"\n%@", postArray[i]];
    }
    NSLog(@"%@", postString);
    
    
    [self.view endEditing:YES];
}
#pragma mark 相册
-(void)imageBtnClick
{
    _textViewRange = _textView.selectedRange;
    TZImagePickerController *controller = [[TZImagePickerController alloc] initWithMaxImagesCount:5 delegate:self];
    [self presentViewController:controller animated:YES completion:nil];
}
#pragma mark - TZImage Picker Controller Delegate
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto {
    
    _textViewRange = _textView.selectedRange;
    NSMutableAttributedString *contentText = [_textView.attributedText mutableCopy];
    for (NSInteger i = photos.count - 1; i >= 0; i--) {
        
        UIImage * image = photos[i];
        
        //此处省略了调用七牛上传图片，拼接得到图片的url
        
        NSString*altStr = [NSString stringWithFormat:@"http://7xojj3.com1.z0.glb.clouddn.com/image/sharepic/%@",@"imageName"];
        CustomYYImage *imageView = [[CustomYYImage alloc] initWithDataSourece:self];
        
        
        imageView.imageW = image.size.width;
        imageView.imageH = image.size.height;
        
        float scale = (SIZE.width-30)/image.size.width;
        image = [self imageByScalingAndCroppingForSize:CGSizeMake(SIZE.width-30, image.size.height*scale) forImage:image];
        imageView.image = image;
        imageView.urlStr = altStr;
        imageView.location = _textViewRange.location + i * 2 + 1;
        contentText = [[self p_textViewAttributedText:imageView contentText:contentText index:_textViewRange.location originPoint:[_textView caretRectForPosition:_textView.selectedTextRange.start].origin isData:NO] mutableCopy];
        
        [contentText insertAttributedString:[[NSAttributedString alloc] initWithString:@"\n"] atIndex:_textViewRange.location + 1 * 2];
    }
    //    [contentText insertAttributedString:[[NSAttributedString alloc] initWithString:@"\n"] atIndex:_textViewRange.location + photos.count * 2];
    [contentText setYy_font:[UIFont systemFontOfSize:16]];
    contentText.yy_lineSpacing = 15;
    _textView.attributedText = contentText;
    self.textView.selectedRange = NSMakeRange(contentText.length, 0);
}

#pragma mark 相机
-(void)cameraBtnClick
{
    
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        //设置拍照后的图片可被编辑
        picker.allowsEditing = YES;
        picker.sourceType = sourceType;
        [self presentViewController:picker animated:YES completion:nil];
    }
}


#pragma mark 弹下
-(void)btnClick
{
    [self.view endEditing:YES];
}

#pragma mark -相册代理
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    _textViewRange = _textView.selectedRange;
    UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
 
    //此处省略了调用七牛上传图片，拼接得到图片的url
    
    NSMutableAttributedString *contentText = [_textView.attributedText mutableCopy];
    NSString*altStr = [NSString stringWithFormat:@"http://7xojj3.com1.z0.glb.clouddn.com/image/sharepic/%@",@"imageName"];
    CustomYYImage *imageView = [[CustomYYImage alloc] initWithDataSourece:self];
    imageView.imageW = image.size.width;
    imageView.imageH = image.size.height;
    imageView.urlStr = altStr;
    float scale = (SIZE.width-30)/image.size.width;
    image = [self imageByScalingAndCroppingForSize:CGSizeMake(SIZE.width-30, image.size.height*scale) forImage:image];
    imageView.image = image;
    
    
    imageView.location = _textViewRange.location + 0 * 2 + 1;
    contentText = [[self p_textViewAttributedText:imageView contentText:contentText index:_textViewRange.location originPoint:[_textView caretRectForPosition:_textView.selectedTextRange.start].origin isData:NO] mutableCopy];
    [contentText insertAttributedString:[[NSAttributedString alloc] initWithString:@"\n"] atIndex:_textViewRange.location + 1 * 2];
    [contentText setYy_font:[UIFont systemFontOfSize:16]];
    contentText.yy_lineSpacing = 15;
    _textView.attributedText = contentText;
    self.textView.selectedRange = NSMakeRange(contentText.length, 0);
    
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
    
    
    
}
#pragma mark 当键盘出现或改变时调用
- (void)keyboardWillShow:(NSNotification *)aNotification
{
    //获取键盘的高度
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    keyBoardHeight = keyboardRect.size.height;
    [UIView animateWithDuration:0.1 animations:^{
        self->_textView.frame = CGRectMake(15, 64, SIZE.width-30, SIZE.height-64-self->keyBoardHeight-40-10-15);
        self->_toolView.frame = CGRectMake(0, SIZE.height-self->keyBoardHeight-40, SIZE.width, 40);
    }];
    
}

#pragma mark 当键退出时调用
- (void)keyboardWillHide:(NSNotification *)aNotification
{
    [UIView animateWithDuration:0.1 animations:^{
        self->_textView.frame = CGRectMake(15, 64, SIZE.width-30, SIZE.height-64-10);
        _toolView.frame = CGRectMake(0, SIZE.height+40, SIZE.width, 40);
    }];
}
- (BOOL)textView:(YYTextView *)textView shouldTapHighlight:(YYTextHighlight *)highlight inRange:(NSRange)characterRange
{
    return YES;
}
- (void)textView:(YYTextView *)textView didTapHighlight:(YYTextHighlight *)highlight inRange:(NSRange)characterRange rect:(CGRect)rect
{
    //    if ([self.clickDelegate respondsToSelector:@selector(label:tapHighlight:inRange:)])
    //    {
    //        YYTextHighlight *highlight = [textView.attributedText yy_attribute:YYTextHighlightAttributeName atIndex:characterRange.location];
    //        [self.clickDelegate label:textView tapHighlight:highlight inRange:characterRange];
    //    }
}
- (BOOL)textView:(YYTextView *)textView shouldLongPressHighlight:(YYTextHighlight *)highlight inRange:(NSRange)characterRange
{
    
    return YES;
}
- (void)textView:(YYTextView *)textView didLongPressHighlight:(YYTextHighlight *)highlight inRange:(NSRange)characterRange rect:(CGRect)rect
{
    
}

#pragma mark - YYTextView Get Attributed String
- (NSAttributedString *)p_textViewAttributedText:(id)attribute contentText:(NSAttributedString *)attributeString index:(NSInteger)index originPoint:(CGPoint)originPoint isData:(BOOL)isData {
    NSMutableAttributedString *contentText = [attributeString mutableCopy];
    NSAttributedString *textAttachmentString = [[NSAttributedString alloc] initWithString:@"\n"];
    if ([attribute isKindOfClass:[CustomYYImage class]]) {
        CustomYYImage *imageView = (CustomYYImage *)attribute;
        CGFloat imageViewHeight = ![imageView.title isEqualToString:@""] ? SIZE.width + 30.0 : SIZE.width;
        float scale = (SIZE.width-30)/imageView.imageW;
        imageView.frame = CGRectMake(originPoint.x, originPoint.y, SIZE.width-30, imageView.imageH*scale);
        //        imageView.frame = CGRectMake(originPoint.x, originPoint.y, SIZE.width-30, 200);
        
        NSMutableAttributedString *attachText = [NSMutableAttributedString yy_attachmentStringWithContent:imageView contentMode:UIViewContentModeScaleAspectFit attachmentSize:imageView.frame.size alignToFont:_textView.font alignment:YYTextVerticalAlignmentCenter];
        if (!isData) [contentText insertAttributedString:textAttachmentString atIndex:index++];
        [contentText insertAttributedString:attachText atIndex:index++];
        
        
    }
    return contentText;
}
//图片伸缩到指定大小
- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize forImage:(UIImage *)originImage
{
    UIImage *sourceImage = originImage;// 原图
    UIImage *newImage = nil;// 新图
    // 原图尺寸
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;// 目标宽度
    CGFloat targetHeight = targetSize.height;// 目标高度
    // 伸缩参数初始化
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {// 如果原尺寸与目标尺寸不同才执行
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // 根据宽度伸缩
        else
            scaleFactor = heightFactor; // 根据高度伸缩
        scaledWidth= width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // 定位图片的中心点
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else if (widthFactor < heightFactor)
        {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    // 创建基于位图的上下文
    UIGraphicsBeginImageContext(targetSize);
    
    // 目标尺寸
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width= scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    // 新图片
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil)
        NSLog(@"could not scale image");
    
    // 退出位图上下文
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark - trim
- (NSArray *)p_trimIsMove:(BOOL)isMove {
    NSInteger currentIndex = 0;
    NSString *dataString = _textView.attributedText.string;
    NSMutableArray *data = [[dataString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] mutableCopy];
    NSMutableArray *result = [NSMutableArray new];
    for (int i = 0; i < data.count; i++) {
        BOOL isChangedIndex = NO;
        int attachmentIndex = 0;
        for (int j = attachmentIndex; j < _textView.textLayout.attachmentRanges.count; j++) {
            if ([_textView.textLayout.attachmentRanges[j] rangeValue].location == currentIndex) {
                if ([_textView.textLayout.attachments[j].content isKindOfClass:[CustomYYImage class]])
                {
                    CustomYYImage *imageView = _textView.textLayout.attachments[j].content;
                    if (!isChangedIndex) {
                        if (isMove) {
                            [result addObject:imageView];
                        } else {
                            ImageModel *model = [ImageModel new];
                            model.image = imageView.image;
                            model.abbrUrl = imageView.urlStr;
                            if (imageView.title) model.title = imageView.title;
                            [result addObject:model];
                        }
                        currentIndex += 2;
                        isChangedIndex = YES;
                        attachmentIndex ++;
                    }
                }
            }
        }
        if (!isChangedIndex) {
            NSString *string = data[i];
            currentIndex += string.length + 1;
            if (![string isEqualToString:@""]) {
                [result addObject:string];
            }
        }
    }
    return result;
}

#pragma mark --NavClickDelegate--
-(void)btnNavLeftClick
{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
