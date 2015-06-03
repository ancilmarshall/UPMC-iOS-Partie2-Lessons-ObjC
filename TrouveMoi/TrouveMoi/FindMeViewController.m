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

static NSString* kCollectionViewCellReuseIdentifier = @"CollectionViewCell";

@interface FindMeViewController ()  <UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *findMeButton;
@property (weak, nonatomic) IBOutlet UICollectionView *locationDataTopCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *locationDataBottomCollectionView;
@property (weak, nonatomic) IBOutlet UILabel *timeLocationData;
@property (weak, nonatomic) IBOutlet UITextView *localisationData;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *localisationDataHeight;

@property (nonatomic,strong) CLLocationManager* locationManager;
@property (nonatomic,strong) CLLocation* currentLocation;
@property (nonatomic,strong) CLHeading* currentHeading;
@property (nonatomic,assign) BOOL updatingLocation;
@property (nonatomic,strong) NSDateFormatter* dateFormatter;
@end

@implementation FindMeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //NOTE: collection view delegates and data sources are connected in IB
    //Register nib to collection views
    [self.locationDataTopCollectionView registerNib:[UINib nibWithNibName:@"FindMeCollectionViewCell" bundle:nil]
                         forCellWithReuseIdentifier:kCollectionViewCellReuseIdentifier];
    
    [self.locationDataBottomCollectionView registerNib:[UINib nibWithNibName:@"FindMeCollectionViewCell" bundle:nil]
                            forCellWithReuseIdentifier:kCollectionViewCellReuseIdentifier];
    
    //reset the views' background color from what was set in IB
    self.locationDataTopCollectionView.backgroundColor = [UIColor whiteColor];
    self.locationDataBottomCollectionView.backgroundColor = [UIColor whiteColor];
    self.localisationData.backgroundColor = [UIColor whiteColor];
    
    //reset the state and call [self resetUI]
    [self reset];
    
    self.dateFormatter = [NSDateFormatter new];
    self.dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    self.dateFormatter.timeStyle = NSDateFormatterMediumStyle;
    
}

#pragma mark - Location Services

- (IBAction)findLocation:(UIButton *)sender {
    
    NSAssert(self.findMeButton == sender,NSLocalizedString(@"Expected event source to be the findMe button",nil));
    
    //if already in updating mode, then reset the data and the ui
    if (self.updatingLocation == YES){
        [self reset];
        return;
    }
    
    //otherwise create a new location manager
    self.locationManager = [CLLocationManager new];
    self.locationManager.distanceFilter = kCLLocationAccuracyBest;
    self.locationManager.delegate = self;
    
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
            
        case kCLAuthorizationStatusDenied:
        case kCLAuthorizationStatusRestricted:
            return;
        
        case kCLAuthorizationStatusNotDetermined:
            [self.locationManager requestWhenInUseAuthorization];
            return;
            
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        case kCLAuthorizationStatusAuthorizedAlways:
            [self startUpdatingLocation];
            return;
            
        default:
            break;
    }
}

-(void)startUpdatingLocation;
{
    [self.locationManager startUpdatingLocation];
    self.updatingLocation = YES;
    
    if ([CLLocationManager headingAvailable]){
        [self.locationManager startUpdatingHeading];
    }
    
    self.localisationData.text = NSLocalizedString(@"Searching ...", nil);
    [self.findMeButton setTitle:NSLocalizedString(@"Stop...", nil) forState:UIControlStateNormal];
}

-(void)reset;
{
    self.locationManager.delegate = nil;
    [self.locationManager stopUpdatingLocation];
    
    if ([CLLocationManager headingAvailable]) {
        [self.locationManager stopUpdatingHeading];
    }
    
    self.updatingLocation = NO;
    self.locationManager = nil;
    self.currentLocation = nil;
    self.currentHeading = nil;

    [self.findMeButton setTitle:NSLocalizedString(@"Find Me", nil) forState:UIControlStateNormal];
    
    [self resetUI];
}

// call with the default size argument as the view's size
-(void)resetUI;
{
    [self resetUIForSize:self.view.frame.size];
}

// size is an optional parameter
-(void)resetUIForSize:(CGSize)size;
{
    [self.locationDataBottomCollectionView reloadData];
    [self.locationDataTopCollectionView reloadData];
    
    if (self.updatingLocation){
        self.localisationData.text = self.currentLocation.description;
        self.timeLocationData.text = [self.dateFormatter stringFromDate:self.currentLocation.timestamp];
    }
    else{
        self.localisationData.text = NSLocalizedString(@"Location data details",nil);
        self.timeLocationData.text = NSLocalizedString(@"Location date", nil);
    }
    
    //TODO: This should not be hard coded, but rather varied based on the content
    if ([self isPortrait:size]){
        self.localisationDataHeight.constant = 100;
    }
    else {
        self.localisationDataHeight.constant = 50;
    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations;
{
    self.currentLocation = locations[0];
    if (self.currentLocation != nil){
        [self resetUI];
    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading;
{
    self.currentHeading = newHeading;
    if (self.currentHeading != nil){
        [self resetUI];
    }
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error;
{
    [self resetUI];
    NSString* text = [NSString stringWithFormat:
                      NSLocalizedString(@"Error getting localisation data: %@", nil),error.description];
    self.localisationData.text = text;
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
    else {
        NSAssert(NO,NSLocalizedString(@"Unexpected collectionView",nil));
    }
    return 0;
}

- (FindMeCollectionViewCell *)collectionView:(UICollectionView *)collectionView
                      cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    FindMeCollectionViewCell* cell =[collectionView
           dequeueReusableCellWithReuseIdentifier:kCollectionViewCellReuseIdentifier
           forIndexPath:indexPath];
    NSAssert(cell != nil, NSLocalizedString(@"Expected to have a UICollectionViewCell",nil));
    //bc collection views always guarantees non-nil cells, unlike tableview
    
    if (collectionView == self.locationDataTopCollectionView){
        cell.text = [self topLocationDataLabels][indexPath.item];
    } else if (collectionView == self.locationDataBottomCollectionView) {
        cell.text = [self bottomLocationDataLabels][indexPath.item];
    } else {
        NSAssert(NO,NSLocalizedString(@"Unexpected collectionView",nil));
    }
    return cell;
}

#pragma mark - UICollectionViewFlowLayoutDelegate

-(CGSize)collectionView:(UICollectionView *)collectionView
                 layout:(UICollectionViewLayout *)collectionViewLayout
 sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 50.0f;
    CGFloat width = (self.locationDataTopCollectionView.frame.size.width / 2.0f)-8.0f;
    //NOTE: needed this offset of 8.0f to work when embedded in a tab controller. Don't know why?
    CGSize size =  (CGSize){.width = width, .height=height};
    return size;
}

# pragma mark - Localisation Data Label Text Inputs

-(NSArray*)topLocationDataLabels;
{
 
    if (self.currentLocation == nil){
    
        return @[ NSLocalizedString(@"Lat: ---",nil),
                  NSLocalizedString(@"Long: ---", nil),
                  NSLocalizedString(@"Alt: ---", nil),
                  NSLocalizedString(@"Speed: ---", nil)];
    }
    
    NSMutableArray* dataLabelsArray = [NSMutableArray new];
    [dataLabelsArray addObject:[NSString stringWithFormat:
        NSLocalizedString(@"Lat: %.3f",nil),self.currentLocation.coordinate.latitude]];
    [dataLabelsArray addObject:[NSString stringWithFormat:
        NSLocalizedString(@"Long: %.3f",nil),self.currentLocation.coordinate.longitude]];
    [dataLabelsArray addObject:[NSString stringWithFormat:
        NSLocalizedString(@"Alt: %.3f",nil),self.currentLocation.altitude]];
    [dataLabelsArray addObject:[NSString stringWithFormat:
        NSLocalizedString(@"Speed: %.3f",nil),self.currentLocation.speed]];
    
    return [NSArray arrayWithArray:dataLabelsArray];;
}

-(NSArray*)bottomLocationDataLabels;
{
    
    if (self.currentHeading == nil){
        return @[ NSLocalizedString(@"Heading T: ---", nil),
                  NSLocalizedString(@"Heading M: ---",nil),
                  NSLocalizedString(@"x-comp: ---", nil),
                  NSLocalizedString(@"y-comp: ---", nil)];
    }
    
    NSMutableArray* dataLabelsArray = [NSMutableArray new];
    [dataLabelsArray addObject:[NSString stringWithFormat:
        NSLocalizedString(@"Heading T:%.3f",nil),self.currentHeading.trueHeading]];
    [dataLabelsArray addObject:[NSString stringWithFormat:
        NSLocalizedString(@"Heading M: %.3f",nil),self.currentHeading.magneticHeading]];
    [dataLabelsArray addObject:[NSString stringWithFormat:
        NSLocalizedString(@"x-comp: %.3f",nil),self.currentHeading.x]];
    [dataLabelsArray addObject:[NSString stringWithFormat:
        NSLocalizedString(@"y-comp: %.3f",nil),self.currentHeading.y]];
    
    return [NSArray arrayWithArray:dataLabelsArray];
    
}

#pragma mark - Rotation support

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self resetUIForSize:size];
    } completion:nil];
}

-(BOOL)isPortrait:(CGSize)size;
{
    return size.height > size.width;
}

@end
