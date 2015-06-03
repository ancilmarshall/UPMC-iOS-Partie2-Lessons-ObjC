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

static NSUInteger counter = 1;

@interface FindMeMap2DViewController ()<MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView* map;
@property (weak, nonatomic) IBOutlet UISegmentedControl *mapTypePicker;
@property (nonatomic,assign) BOOL reinitMapAboutUserLocation;

@end

@implementation FindMeMap2DViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //mapview ( the delegate is connected in the IB )
    self.map.mapType = MKMapTypeStandard;
    self.map.zoomEnabled = YES;
    self.map.scrollEnabled = YES;
    self.map.rotateEnabled = YES;
    self.map.pitchEnabled = NO;
    self.mapTypePicker.selectedSegmentIndex = 0;
    self.reinitMapAboutUserLocation = YES;
    
}

#pragma mark - Location Services

-(IBAction)findLocation:(UIButton *)sender;
{
    [super findLocation:sender];
    self.reinitMapAboutUserLocation = YES;
    
}

-(void)resetUIForSize:(CGSize)size;
{
    [super resetUIForSize:size];
    [self resetMap];
}

-(void)resetMap;
{
    if (self.currentLocation != nil){
        if (self.reinitMapAboutUserLocation == YES){ //flag used to reinit displayed region
            CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(
                                            self.currentLocation.coordinate.latitude,
                                            self.currentLocation.coordinate.longitude);
            MKCoordinateSpan span = MKCoordinateSpanMake(0.035, 0.035);
            MKCoordinateRegion region = MKCoordinateRegionMake(coord, span);
            [self.map setRegion:region animated:YES];
        }
        self.map.showsUserLocation = YES;
    }
    else {
        self.map.showsUserLocation = NO;
    }
    [self.map setNeedsDisplay];
    self.reinitMapAboutUserLocation = NO;
}

- (IBAction)reinitMap:(UIBarButtonItem *)sender {
    self.reinitMapAboutUserLocation = YES;
    [self resetMap];
}


# pragma mark -  Pin Annotation View
- (IBAction)addPin:(UIButton *)sender {
    
    MKPointAnnotation* annotation = [MKPointAnnotation new];
    annotation.title = [NSString stringWithFormat:@"Point %tu",counter++];
    annotation.coordinate = [self.map centerCoordinate];
    [self.map addAnnotation:annotation];
}

- (MKAnnotationView*)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if (annotation==[mapView userLocation]){
        return nil;
    }
    
    MKPinAnnotationView* pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pinAnnotationView"];
    pin.pinColor = MKPinAnnotationColorPurple;
    pin.canShowCallout = YES;
    pin.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    pin.animatesDrop = YES;

    return pin;
}

- (IBAction)changeMapType:(UISegmentedControl *)sender {
    NSAssert(sender == self.mapTypePicker,
             NSLocalizedString(@"Expected event sender to by the mapTypePicker segmented control button",nil));
    
    switch (sender.selectedSegmentIndex) {
        case 0:
            self.map.mapType = MKMapTypeStandard;
            break;
            
        case 1:
            self.map.mapType = MKMapTypeSatellite;
            break;
            
        case 2:
            self.map.mapType = MKMapTypeHybrid;
            break;
            
        default:
            break;
    }
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

@end
