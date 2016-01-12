//
//  KGModalDelegate.h
//  ManaSoMe
//
//  Created by Quoc Anh Nguyen on 9/8/15.
//  Copyright (c) 2015 AnhNguyen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KGModal;
@protocol KGModalDelegate <NSObject>
-(void) kgModalClosed:(KGModal* )kgModal;
@end
