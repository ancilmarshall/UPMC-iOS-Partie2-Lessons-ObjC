//
//  FindMeCollectionViewCell.m
//  TrouveMoi
//
//  Created by Ancil on 4/27/15.
//  Copyright (c) 2015 Ancil Marshall. All rights reserved.
//

#import "FindMeCollectionViewCell.h"


@interface FindMeCollectionViewCell()
@property (weak, nonatomic) IBOutlet UILabel *title;
@end

@implementation FindMeCollectionViewCell

//nice trick to use the setter on the text property
//reduces a layer of abstraction when setting the cell's text
-(void)setText:(NSString *)text;
{
    self.title.text = text;
}

@end
