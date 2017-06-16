//
//  UIColor+DLAdd.h
//  Dolores
//
//  Created by Heath on 24/04/2017.
//  Copyright © 2017 Dolores. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (DLAdd)

/**
 * tableview分割线
 * @return
 */
+ (UIColor *)dl_ironColor;

+ (UIColor *)dl_textColorStyle1;

/**
 * tableview背景色，较淡，灰
 * @return
 */
+ (UIColor *)dl_tableBGColor;

/**
 * 接近最黑
 * @return
 */
+ (UIColor *)dl_leadColor;

+ (UIColor *)dl_separatorColor;
@end