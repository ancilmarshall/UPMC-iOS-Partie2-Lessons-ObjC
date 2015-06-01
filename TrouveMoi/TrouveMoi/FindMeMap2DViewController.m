//
//  FindMeMap2DViewController.m
//  TrouveMoi
//
//  Created by Ancil on 6/1/15.
//  Copyright (c) 2015 Ancil Marshall. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

#import "FindMeMap2DViewController.h"
#import "FindMeCollectionViewCell.h"

static NSString* kCollectionViewCellReuseIdentifier = @"CollectionViewCell";

@interface FindMeMap2DViewController ()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,
    CLLocationManagerDelegate,MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *findMeButton;
@property (weak, nonatomic) IBOutlet UICollectionView *locationDataTopCollectionView;
@property (weak, nonatomic) IBOutlet UILabel *timeLocationData;
@property (weak, nonatomic) IBOutlet UITextView *localisationData;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *localisationDataHeight;
@property (weak, nonatomic) IBOutlet MKMapView* map;

@property (nonatomic,strong) CLLocationManager* locationManager;
@property (nonatomic,strong) CLLocation* currentLocation;
@property (nonatomic,strong) NSDateFormatter* dateFormatter;
@property (nonatomic,assign) BOOL updatingLocation;

@end

@implementation FindMeMap2DViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //NOTE: collection view delegates and data sources are connected in IB
    //Register nib to collection views
    [self.locationDataTopCollectionView registerNib:[UINib nibWithNibName:@"FindMeCollectionViewCell" bundle:nil]
                         forCellWithReuseIdentifier:kCollectionViewCellReuseIdentifier];
    
    //reset the views' background color from what was set in IB
    self.locationDataTopCollectionView.backgroundColor = [UIColor whiteColor];
    self.localisationData.backgroundColor = [UIColor whiteColor];
    
    //reset the state and call [self resetUI]
    [self reset];
    
    self.dateFormatter = [NSDateFormatter new];
    self.dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    self.dateFormatter.timeStyle = NSDateFormatterMediumStyle;
    
    //mapview
    self.map.mapType = MKMapTypeStandard;
    self.map.zoomEnabled = YES;
    self.map.scrollEnabled = YES;
    self.map.rotateEnabled = YES;
    self.map.pitchEnabled = NO;
    
    self.map.delegate = self;
    
}

#pragma mark - Location Services

- (IBAction)findLocation:(UIButton *)sender {
    
    NSAssert(self.findMeButton == sender,@"Expected event source to be the findMe button");
    
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

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error;
{
    [self resetUI];
    NSString* text = [NSString stringWithFormat:NSLocalizedString(@"Error getting localisation data: %@", nil),error.description];
    self.localisationData.text = text;
}


# pragma mark - Add Pin
- (IBAction)addPin:(UIButton *)sender {
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
    NSAssert(cell != nil, @"Expected to have a UICollectionViewCell");
    //bc collection views always guarantees non-nil cells, unlike tableview
    
    if (collectionView == self.locationDataTopCollectionView){
        cell.text = [self topLocationDataLabels][indexPath.item];
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
    CGFloat width = (self.locationDataTopCollectionView.frame.size.width / 2.0f)-16.0f;
    //NOTE: needed this offset of 8.0f to work when embedded in a tab controller. Don't know why?
    CGSize size =  (CGSize){.width = width, .height=height};
    return size;
}

# pragma mark - Localisation Data Label Text Inputs

-(NSArray*)topLocationDataLabels;
{
    
    if (self.currentLocation == nil){
        
        return @[ NSLocalizedString(@"Lat: ---",nil),
                  NSLocalizedString(@"Long: ---", nil)];
    }
    
    NSMutableArray* dataLabelsArray = [NSMutableArray new];
    [dataLabelsArray addObject:[NSString stringWithFormat:@"Lat: %.3f",self.currentLocation.coordinate.latitude]];
    [dataLabelsArray addObject:[NSString stringWithFormat:@"Long: %.3f",self.currentLocation.coordinate.longitude]];
    
    return [NSArray arrayWithArray:dataLabelsArray];;
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