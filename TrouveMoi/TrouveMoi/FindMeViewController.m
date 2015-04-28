//
//  ViewController.m
//  TrouveMoi
//
//  Created by Ancil on 4/27/15.
//  Copyright (c) 2015 Ancil Marshall. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

#import "FindMeViewController.h"
#import "FindMeCollectionViewCell.h"

static NSString* kTopCollectionViewCellReuseIdentifier = @"TopCollectionViewCell";
static NSString* kBottomCollectionViewCellReuseIdentifier = @"BottomCollectionViewCell";

@interface FindMeViewController ()  <UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *findMeButton;
@property (weak, nonatomic) IBOutlet UICollectionView *locationDataTopCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *locationDataBottomCollectionView;
@property (weak, nonatomic) IBOutlet UILabel *timeLocationData;
@property (weak, nonatomic) IBOutlet UITextView *localisationData;

@property (nonatomic,strong) CLLocationManager* locationManager;
@property (nonatomic,assign) BOOL updatingLocation;
@end

@implementation FindMeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //NOTE: collection view delegates and data sources are connected in IB
    
    //Register nib to collection views
    [self.locationDataTopCollectionView registerNib:[UINib nibWithNibName:@"FindMeCollectionViewCell" bundle:nil]
                         forCellWithReuseIdentifier:kTopCollectionViewCellReuseIdentifier];
    
    [self.locationDataBottomCollectionView registerNib:[UINib nibWithNibName:@"FindMeCollectionViewCell" bundle:nil]
                            forCellWithReuseIdentifier:kBottomCollectionViewCellReuseIdentifier];
    
    //reset the views' background color from what was set in IB
    self.locationDataTopCollectionView.backgroundColor = [UIColor whiteColor];
    self.locationDataBottomCollectionView.backgroundColor = [UIColor whiteColor];
    self.localisationData.backgroundColor = [UIColor whiteColor];
    
    [self resetLocationUpdates];
    
}


#pragma mark - Location Services
//lazy initialization of the location manager
-(CLLocationManager*)locationManager;
{
    if (_locationManager == nil){
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
    }
    return _locationManager;
}

- (IBAction)findLocation:(UIButton *)sender {
    
    NSAssert(self.findMeButton == sender,@"Expected event source to be the findMe button");
    
    if (self.updatingLocation == YES){
        [self resetLocationUpdates];
        return;
    }
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse){
        [self startUpdatingLocation];
    }
    else
    {
        if (![CLLocationManager locationServicesEnabled]){
            UIAlertController* alertController = [[UIAlertController alloc] init];
            
            alertController.title = NSLocalizedString(@"Location Services Not Available",nil);
            UIAlertAction* action = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                             style:UIAlertActionStyleDefault
                                                           handler:nil];
            [alertController addAction:action];
            [self presentViewController:alertController animated:YES completion:nil];
        }
        else
        {
            [self.locationManager requestWhenInUseAuthorization];
        }
    }
}

//This delegate is called after the requestWhenInUseAuthorization returns the results from the user
-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status;
{
    NSAssert(manager == self.locationManager,NSLocalizedString(@"Expected event's manager to be self.locationManager",nil));
    
    switch (status) {
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            [self startUpdatingLocation];
            break;
            
        default:
            break;
    }
}

-(void)startUpdatingLocation;
{
    [self.locationManager startUpdatingLocation];
    self.updatingLocation = YES;
    self.findMeButton.titleLabel.text = NSLocalizedString(@"Stop...", nil);
}

-(void)resetLocationUpdates;
{
    [self.locationManager stopUpdatingLocation];
    self.updatingLocation = NO;
    self.findMeButton.titleLabel.text = NSLocalizedString(@"Find me", nil);
}

# pragma mark - Collection View Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    
    if (collectionView == self.locationDataTopCollectionView){
        return [[self topLocationDataLabels] count];
    }
    else if (collectionView == self.locationDataBottomCollectionView){
        return [[self bottomLocationDataLabels] count];
    }
    
    return 0;
}

- (FindMeCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    FindMeCollectionViewCell* cell = nil;
    
    if (collectionView == self.locationDataTopCollectionView){
    
        cell =[collectionView
               dequeueReusableCellWithReuseIdentifier:kTopCollectionViewCellReuseIdentifier
                                        forIndexPath:indexPath];
        NSAssert( cell != nil, @"Expected to have a UICollectionViewCell");
        //bc collection views always guarantees non-nil cells, unlike tableview

        cell.title.text = [self topLocationDataLabels][indexPath.item];
        
    } else if (collectionView == self.locationDataBottomCollectionView) {
        cell =[collectionView
               dequeueReusableCellWithReuseIdentifier:kBottomCollectionViewCellReuseIdentifier
                                         forIndexPath:indexPath];
        NSAssert( cell != nil, @"Expected to have a UICollectionViewCell");
        //bc collection views always guarantees non-nil cells, unlike tableview
        
        cell.title.text = [self bottomLocationDataLabels][indexPath.item];
    }
    return cell;
}

#pragma mark - UICollectionViewFlowLayoutDelegate

-(CGSize)collectionView:(UICollectionView *)collectionView
                 layout:(UICollectionViewLayout *)collectionViewLayout
 sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 50.0f;
    CGFloat width = self.locationDataTopCollectionView.bounds.size.width / 2.0f;
    CGSize size =  (CGSize){.width = width, .height=height};
    
    return size;
}


# pragma mark - Localisation Data Label Text Inputs

-(NSArray*)topLocationDataLabels;
{
    
    return @[ NSLocalizedString(@"Lat:",nil),
              NSLocalizedString(@"Long:", nil),
              NSLocalizedString(@"Alt:", nil),
              NSLocalizedString(@"Speed:", nil)];
}

-(NSArray*)bottomLocationDataLabels;
{
    return @[ NSLocalizedString(@"Heading T:", nil),
              NSLocalizedString(@"Heading M:",nil),
              NSLocalizedString(@"x-comp", nil),
              NSLocalizedString(@"y-comp", nil)];
}

#pragma mark - Rotation support

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [self.locationDataTopCollectionView reloadData]; // just update the UI here
    [self.locationDataBottomCollectionView reloadData];
}

@end
