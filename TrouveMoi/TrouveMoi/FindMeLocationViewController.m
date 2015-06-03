//
//  ViewController.m
//  TrouveMoi
//
//  Created by Ancil on 4/27/15.
//  Copyright (c) 2015 Ancil Marshall. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

#import "FindMeLocationViewController.h"
#import "FindMeCollectionViewCell.h"


@interface FindMeLocationViewController () 

@property (weak, nonatomic) IBOutlet UICollectionView *locationDataBottomCollectionView;
@property (nonatomic,strong) CLHeading* currentHeading;

@end

@implementation FindMeLocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.locationDataBottomCollectionView
     registerNib:[UINib nibWithNibName:@"FindMeCollectionViewCell" bundle:nil]
     forCellWithReuseIdentifier:kCollectionViewCellReuseIdentifier];
    self.locationDataBottomCollectionView.backgroundColor = [UIColor whiteColor];
    
}

#pragma mark - Location Services

-(void)startUpdatingLocation;
{
    [super startUpdatingLocation];
    
    if ([CLLocationManager headingAvailable]){
        [self.locationManager startUpdatingHeading];
    }
}


-(void)reset;
{
    [super reset];

    if ([CLLocationManager headingAvailable]) {
        [self.locationManager stopUpdatingHeading];
    }
    self.currentHeading = nil;
    
}

// size is an optional parameter
-(void)resetUIForSize:(CGSize)size;
{
    [super resetUIForSize:size];
    [self.locationDataBottomCollectionView reloadData];
}


-(void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading;
{
    self.currentHeading = newHeading;
    if (self.currentHeading != nil){
        [self resetUI];
    }
}

# pragma mark - Collection View Data Source
- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    
    NSInteger num = [super collectionView:collectionView numberOfItemsInSection:section];
    
    if (collectionView == self.locationDataBottomCollectionView){
        num =  [[self bottomLocationDataLabels] count];
    }
    return num;
}

- (FindMeCollectionViewCell *)collectionView:(UICollectionView *)collectionView
                      cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    FindMeCollectionViewCell* cell = (FindMeCollectionViewCell*)
    [super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    if (collectionView == self.locationDataBottomCollectionView) {
        cell.text = [self bottomLocationDataLabels][indexPath.item];
    }
    return cell;
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


@end
