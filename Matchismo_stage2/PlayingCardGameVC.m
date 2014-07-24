//
//  PlayingCardGameVC.m
//  Matchismo_stage2
//
//  Created by Olga on 24/07/14.
//  Copyright (c) 2014 Olga. All rights reserved.
//

#import "PlayingCardGameVC.h"
#import "PlayingCardDeck.h"

@interface PlayingCardGameVC ()

@end

@implementation PlayingCardGameVC

-(Deck *)createDeck
{
  NSLog(@"PlayingCardGameVC: createDeck");
  return [[PlayingCardDeck alloc] init];
}

-(NSUInteger)numOfCardsToMatch {
  NSLog(@"PlayingCardGameVC: set num of cards to match (2 for the playing card game)");
  return 2;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
