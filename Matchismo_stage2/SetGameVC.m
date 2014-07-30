//
//  SetGameVC.m
//  Matchismo_stage2
//
//  Created by Olga on 24/07/14.
//  Copyright (c) 2014 Olga. All rights reserved.
//

#import "SetGameVC.h"
#import "SetCardDeck.h"
#import "SetCard.h"
#import "SetCardView.h"

@interface SetGameVC ()
@property (weak, nonatomic) IBOutlet UIButton *moreCardsButton;

@end

@implementation SetGameVC

// Request more cards to be added to the current Set game
- (IBAction)touchMoreCardsButton:(id)sender
{
}


- (void)viewDidLoad
{
  [super viewDidLoad];
    // Do any additional setup after loading the view.
  
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Virtual Methods Implementation

#define DEFAULT_NUM_OF_CARDS_IN_SET_CARD_GAME 16
#define NUMBER_OF_CARDS_TO_MATCH_IN_SET_CARD_GAME 3

- (Deck *)createDeck
{
  NSLog(@"SetGameVC: createDeck");
  return [[SetCardDeck alloc] init];
}

- (NSUInteger)numOfCardsToMatch {
  NSLog(@"SetGameVC: set num of cards to match 3");
  return NUMBER_OF_CARDS_TO_MATCH_IN_SET_CARD_GAME;
}

- (NSUInteger)defaultNumOfCardsInGame {
  NSLog(@"SetGameVC: defaultNumOfCardsInGame");
  return DEFAULT_NUM_OF_CARDS_IN_SET_CARD_GAME;
}


- (CardView *)createCardViewWithFrame:(CGRect)frame withCard:(Card *)card
{
  SetCardView *setCardView = nil;
  
  if ([card isKindOfClass:[SetCard class]]) {
    SetCard *setCard = (SetCard *)card;
    setCardView = [[SetCardView alloc] initWithFrame:frame withCard:setCard];
  } else {
    // TODO - exception
    NSLog(@"PlayingCardGameVC: createCardViewWithCard - incompatible parameter type");
  }
  
  return setCardView;
}

// Set card is usually more square than the playing card
#define DEFAULT_SET_CARD_ASPECT_RATIO  0.55

- (CGFloat)getCardAspectRatio
{
  return DEFAULT_SET_CARD_ASPECT_RATIO;
}

@end
