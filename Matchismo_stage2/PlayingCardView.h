//
//  PlayingCardView.h
//  Matchismo_stage2
//
//  Created by Olga on 24/07/14.
//  Copyright (c) 2014 Olga. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardView.h"

@interface PlayingCardView : CardView

// TODO - these properties should come from Card model.
@property (nonatomic) NSUInteger rank;
@property (strong, nonatomic) NSString *suit;

// TODO - move these to CardView
@property (nonatomic) BOOL faceUp;

- (void) pinch:(UIPinchGestureRecognizer *)gesture;

@end
