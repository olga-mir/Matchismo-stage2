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
#import "Utils.h"

@interface SetGameVC ()

@end

@implementation SetGameVC


- (void)viewDidLoad
{
  NSLog(@"\n\nSetCardGameVC: viewDidLoad");
  
  [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Virtual Methods Implementation

#define DEFAULT_NUM_OF_CARDS_IN_SET_CARD_GAME 12
#define NUMBER_OF_CARDS_TO_MATCH_IN_SET_CARD_GAME 3

- (Deck *)createDeck
{
  return [[SetCardDeck alloc] init];
}

- (NSUInteger)numOfCardsToMatch {
  return NUMBER_OF_CARDS_TO_MATCH_IN_SET_CARD_GAME;
}

- (NSUInteger)defaultNumOfCardsInGame {
  return DEFAULT_NUM_OF_CARDS_IN_SET_CARD_GAME;
}


- (CardView *)createCardViewWithFrame:(CGRect)frame withCard:(Card *)card
{
  SetCardView *setCardView = nil;
  
  if ([card isKindOfClass:[SetCard class]]) {
    SetCard *setCard = (SetCard *)card;
    setCardView = [[SetCardView alloc] initWithFrame:frame withCard:setCard];
  } else {
    SYSASSERT(NO, @"PlayingCardGameVC: createCardViewWithCard - incompatible parameter type");
  }
  
  return setCardView;
}


@end
