//
//  EmmmAttachmentWrapperView.h
//  emmmChat
//
//  Created by 李嘉银 on 17/12/2017.
//  Copyright © 2017 李嘉银. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Masonry.h>

@interface EmmmAttachmentWrapperView : UIView
@property(strong,nonatomic)UIImage * image;
-(instancetype)initWithImage:(UIImage *)image;
@end
