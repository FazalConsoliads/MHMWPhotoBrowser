//
//  MWViewController.h
//  MHMWPhotoBrowser
//
//  Created by FazalConsoliads on 08/22/2021.
//  Copyright (c) 2021 FazalConsoliads. All rights reserved.
//

@import UIKit;
#import "MWPhotoBrowser.h"

@interface MWViewController : UITableViewController <MWPhotoBrowserDelegate> {
    MWPhotoBrowser *browser;
    NSMutableArray *_selections;
}

@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSMutableArray *thumbs;

@end
