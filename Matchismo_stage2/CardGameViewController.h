//
//  cardGameViewController.h
//  Matchismo_stage2
//
//  Created by Olga on 24/07/14.
//  Copyright (c) 2014 Olga. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Deck.h"

@class CardMatchingGame;
@class CardView;
@class Card;


@interface CardGameViewController : UIViewController

// Virtual methods declarations
// If not implemented in subclass, instantiating and using this class will eventually result in Assert.
- (Deck *)createDeck;
- (NSUInteger)numOfCardsToMatch;
- (NSUInteger)defaultNumOfCardsInGame;
- (CardView *)createCardViewWithFrame:(CGRect)frame withCard:(Card *)card;


@end


/*
 BUGS LIST
 
 1. Outlets don't appear when switching from one tab to another
    STEPS: 1. run the app. -> Buttons and score label appear properly
           2. switch to another tab -> the buttons are not visible
 
 2. Orientation is not updated properly sometimes when switching from one mode to another
    STEPS:  1. run app in vertical orientation -> OK
            2. switch orientation to landscape -> OK
            3. switch to another tab -> the orientation of the simulator is landscape, but the cardDisplayArea is portrait
 
 TODOs list (other than scattered in the code
 1. Animate arriaval of the cards (both deal and add more cards functions)
 2. Corner cases 
    1. init game with not enough cards in the deck
    2. add more cards with not enough cards in the deck
 */
