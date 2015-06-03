//
//  FindMeViewController.h
//  TrouveMoi
//
//  Created by Ancil on 6/3/15.
//  Copyright (c) 2015 Ancil Marshall. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

extern NSString* kCollectionViewCellReuseIdentifier;

@interface FindMeViewController : UIViewController
    <CLLocationManagerDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *findMeButton;
@property (weak, nonatomic) IBOutlet UICollectionView *locationDataTopCollectionView;
@property (weak, nonatomic) IBOutlet UILabel *timeLocationData;
@property (weak, nonatomic) IBOutlet UITextView *localisationData;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *localisationDataHeight;

@property (nonatomic,strong) CLLocationManager* locationManager;
@property (nonatomic,strong) CLLocation* currentLocation;
@property (nonatomic,assign) BOOL updatingLocation;
@property (nonatomic,strong) NSDateFormatter* dateFormatter;

- (void)viewDidLoad;
-(IBAction)findLocation:(UIButton *)sender;
-(void)startUpdatingLocation;
-(void)reset;
-(void)resetUI;
-(void)resetUIForSize:(CGSize)size;
-(BOOL)isPortrait:(CGSize)size;
-(NSArray*)topLocationDataLabels;


@end
