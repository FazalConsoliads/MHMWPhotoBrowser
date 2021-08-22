//
//  MWViewController.m
//  MHMWPhotoBrowser
//
//  Created by FazalConsoliads on 08/22/2021.
//  Copyright (c) 2021 FazalConsoliads. All rights reserved.
//

#import "MWViewController.h"

@interface MWViewController ()

@end

@implementation MWViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Create
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    cell.accessoryType = UITableViewCellAccessoryNone;

    // Configure
    switch (indexPath.row) {
        case 0: {
            cell.textLabel.text = @"Photo selection grid";
            cell.detailTextLabel.text = @"selection enabled, start at grid";
            break;
        }
        default: break;
    }
    return cell;
    
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Browser
    NSMutableArray *photos = [[NSMutableArray alloc] init];
    NSMutableArray *thumbs = [[NSMutableArray alloc] init];
    MWPhoto *photo;
    BOOL displayActionButton = NO;
    BOOL displaySelectionButtons = NO;
    BOOL displayNavArrows = NO;
    BOOL enableGrid = YES;
    BOOL startOnGrid = NO;
    BOOL autoPlayOnAppear = NO;
    
    photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"https://impresari-images.s3.amazonaws.com/inventory/1626646575216-20210718_181535.mp4"]];
    photo.videoURL = [NSURL URLWithString:@"https://impresari-images.s3.amazonaws.com/inventory/1626646575216-20210718_181535.mp4"];//:[[NSBundle mainBundle] pathForResource:@"video" ofType:@"mp4"]];
    [photos addObject:photo];
    [thumbs addObject:photo];
    [self fetchThumbnail:[NSURL URLWithString:@"https://impresari-images.s3.amazonaws.com/inventory/1626646575216-20210718_181535.mp4"]];
    photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"https://impresari-images.s3.amazonaws.com/inventory/1626646412665-front.jpg"]];
    [photos addObject:photo];
    [thumbs addObject:photo];
    photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"https://impresari-images.s3.amazonaws.com/inventory/1626646444469-back.jpg"]];
    [photos addObject:photo];
    [thumbs addObject:photo];
    photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"https://impresari-images.s3.amazonaws.com/inventory/1626646474246-left.jpg"]];
    [photos addObject:photo];
    [thumbs addObject:photo];
    photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"https://impresari-images.s3.amazonaws.com/inventory/1626646495066-right.jpg"]];
    [photos addObject:photo];
    [thumbs addObject:photo];
    displayActionButton = NO;
    displaySelectionButtons = YES;
    startOnGrid = indexPath.row == 0;
    enableGrid = NO;
    
    self.photos = photos;
    self.thumbs = thumbs;
    
    // Create browser
    browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.displayActionButton = displayActionButton;
    browser.displayNavArrows = displayNavArrows;
    browser.displaySelectionButtons = displaySelectionButtons;
    browser.alwaysShowControls = displaySelectionButtons;
    browser.zoomPhotosToFill = YES;
    browser.enableGrid = enableGrid;
    browser.startOnGrid = startOnGrid;
    browser.enableSwipeToDismiss = NO;
    browser.autoPlayOnAppear = autoPlayOnAppear;
    [browser setCurrentPhotoIndex:0];
    
    _selections = [NSMutableArray new];
    for (int i = 0; i < photos.count; i++) {
        [_selections addObject:[NSNumber numberWithBool:NO]];
    }
    
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:browser];
    nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:nc animated:YES completion:nil];
    
    // Deselect
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)fetchThumbnail:(NSURL*)urlString {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:urlString options:nil];
        AVAssetImageGenerator *generateImg = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        NSError *error = NULL;
        CMTime time = CMTimeMake(1, 65);
        CGImageRef refImg = [generateImg copyCGImageAtTime:time actualTime:NULL error:&error];
        NSLog(@"error==%@, Refimage==%@", error, refImg);

        UIImage *FrameImage= [[UIImage alloc] initWithCGImage:refImg];
        if (FrameImage != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                MWPhoto* photo = [MWPhoto photoWithImage:FrameImage];
                photo.videoURL = [NSURL URLWithString:@"https://impresari-images.s3.amazonaws.com/inventory/1626646575216-20210718_181535.mp4"];
                [self.photos replaceObjectAtIndex:0 withObject:photo];
                [self.thumbs replaceObjectAtIndex:0 withObject:photo];
                [browser setCurrentPhotoIndex:0];
            });
        }
    });
}

#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _photos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _photos.count)
        return [_photos objectAtIndex:index];
    return nil;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index {
    if (index < _thumbs.count)
        return [_thumbs objectAtIndex:index];
    return nil;
}

//- (MWCaptionView *)photoBrowser:(MWPhotoBrowser *)photoBrowser captionViewForPhotoAtIndex:(NSUInteger)index {
//    MWPhoto *photo = [self.photos objectAtIndex:index];
//    MWCaptionView *captionView = [[MWCaptionView alloc] initWithPhoto:photo];
//    return [captionView autorelease];
//}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser actionButtonPressedForPhotoAtIndex:(NSUInteger)index {
    NSLog(@"ACTION!");
}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index {
    NSLog(@"Did start viewing photo at index %lu", (unsigned long)index);
}

- (BOOL)photoBrowser:(MWPhotoBrowser *)photoBrowser isPhotoSelectedAtIndex:(NSUInteger)index {
    return [[_selections objectAtIndex:index] boolValue];
}

- (NSString *)photoBrowser:(MWPhotoBrowser *)photoBrowser titleForPhotoAtIndex:(NSUInteger)index {
    return @"";//[NSString stringWithFormat:@"Photo %lu", (unsigned long)index+1];
}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index selectedChanged:(BOOL)selected {
    [_selections replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:selected]];
    NSLog(@"Photo at index %lu selected %@", (unsigned long)index, selected ? @"YES" : @"NO");
}

- (void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser {
    // If we subscribe to this method we must dismiss the view controller ourselves
    NSLog(@"Did finish modal presentation");
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
