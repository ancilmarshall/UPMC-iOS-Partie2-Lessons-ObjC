//
//  ViewController.m
//  TrouveMoi
//
//  Created by Ancil on 4/27/15.
//  Copyright (c) 2015 Ancil Marshall. All rights reserved.
//

#import "FindMeViewController.h"

static NSString* kCollectionViewCellReuseIdentifier = @"CollectionViewCell";

@interface FindMeViewController ()  <UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@end

@implementation FindMeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /*  NOTE - Dropped in a UICollectionView on this controller's view
     *  Flow Layout is set in the UICollectionView's properties in the IB
     *  Could set the delegates in the IB or programmatically. I tried both
     */

    // Register cell classes (collection views are made up of cells)
    [self.collectionView registerClass:[UICollectionViewCell class]
            forCellWithReuseIdentifier:kCollectionViewCellReuseIdentifier];
    
    // Set the delegates. DataSource for the data, delegate for the flow layout
    // self.collectionView.dataSource = self;
    // self.collectionView.delegate = self; (used by UICollectionViewFlowLayout object
}

# pragma mark - Collection View Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return [[FindMeViewController geoLocationDataLabels] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    UICollectionViewCell *cell =
    [collectionView dequeueReusableCellWithReuseIdentifier:kCollectionViewCellReuseIdentifier
                                              forIndexPath:indexPath];
    NSAssert( cell != nil, @"Expected to have a UICollectionViewCell");
    //bc collection views always guarantees that a properly allocated cell is in
    // the queue, unlike for tableviews
    
    //cell.bounds = CGRectMake(0.0,0.0,self.view.frame.size.width/2.0,100.0);
    cell.backgroundColor = [self getColor:indexPath.item];
    
    return cell;
}

#pragma mark - UICollectionViewFlowLayoutDelegate

-(CGSize)collectionView:(UICollectionView *)collectionView
                 layout:(UICollectionViewLayout *)collectionViewLayout
 sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 80.0f;
    CGFloat width = self.collectionView.frame.size.width / 2.0f;
    CGSize size =  (CGSize){.width = width, .height=height};
    
    return size;
}


# pragma mark - Helpers

-(UIColor*)getColor:(NSInteger)index;
{
    NSArray* colors = @[
                        [UIColor redColor],
                        [UIColor greenColor],
                        [UIColor blueColor],
                        [UIColor yellowColor]];
    return colors[index];
    
    
}

+(NSArray*)geoLocationDataLabels;
{
    
    return @[ NSLocalizedString(@"Latitude",nil),
              NSLocalizedString(@"Longitude", nil),
              NSLocalizedString(@"Altitude", nil),
              NSLocalizedString(@"Speed", nil)];
    
}

#pragma mark - Rotation support

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [self.collectionView reloadData]; // just update the UI here
}



@end
