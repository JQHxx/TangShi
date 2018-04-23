//
//  EaseBubbleView+Questionnarie.m
//  TangShiService
//
//  Created by vision on 17/12/13.
//  Copyright © 2017年 tianjiyun. All rights reserved.
//

#import "EaseBubbleView+Questionnarie.h"

@implementation EaseBubbleView (Questionnarie)

#pragma mark - private

- (void)_setupQuestionnarieBubbleMarginConstraints
{
    [self.marginConstraints removeAllObjects];
    
    //icon view
    NSLayoutConstraint *questionIconWithMarginTopConstraint = [NSLayoutConstraint constraintWithItem:self.questionIconView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.backgroundImageView attribute:NSLayoutAttributeTop multiplier:1.0 constant:self.margin.top];
    NSLayoutConstraint *questionIconWithMarginBottomConstraint = [NSLayoutConstraint constraintWithItem:self.questionIconView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.backgroundImageView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-self.margin.bottom];
    NSLayoutConstraint *questionIconWithMarginLeftConstraint = [NSLayoutConstraint constraintWithItem:self.questionIconView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.backgroundImageView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:self.margin.left];
    [self.marginConstraints addObject:questionIconWithMarginTopConstraint];
    [self.marginConstraints addObject:questionIconWithMarginBottomConstraint];
    [self.marginConstraints addObject:questionIconWithMarginLeftConstraint];
    
    //name label
    NSLayoutConstraint *questionNameWithMarginTopConstraint = [NSLayoutConstraint constraintWithItem:self.questionNameLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.backgroundImageView attribute:NSLayoutAttributeTop multiplier:1.0 constant:self.margin.top];
    NSLayoutConstraint *questionNameWithMarginRightConstraint = [NSLayoutConstraint constraintWithItem:self.questionNameLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.backgroundImageView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-self.margin.right];
     NSLayoutConstraint *questionNameWithMarginBottomConstraint = [NSLayoutConstraint constraintWithItem:self.questionNameLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.backgroundImageView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-self.margin.bottom];
    [self.marginConstraints addObject:questionNameWithMarginTopConstraint];
    [self.marginConstraints addObject:questionNameWithMarginRightConstraint];
    [self.marginConstraints addObject:questionNameWithMarginBottomConstraint];
    
    
    [self addConstraints:self.marginConstraints];
}

- (void)_setupQuestionnarieBubbleConstraints
{
    [self _setupQuestionnarieBubbleMarginConstraints];
    //icon view
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.questionIconView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.questionIconView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.questionNameLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.questionIconView attribute:NSLayoutAttributeRight multiplier:1.0 constant:EaseMessageCellPadding]];

}

#pragma mark - public

- (void)setupQuestionnarieBubbleView
{
    self.questionIconView = [[UIImageView alloc] init];
    self.questionIconView.translatesAutoresizingMaskIntoConstraints = NO;
    self.questionIconView.backgroundColor = [UIColor clearColor];
    self.questionIconView.clipsToBounds = YES;
    [self.backgroundImageView addSubview:self.questionIconView];
    
    self.questionNameLabel = [[UILabel alloc] init];
    self.questionNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.questionNameLabel.numberOfLines = 0;
    self.questionNameLabel.font=[UIFont systemFontOfSize:14];
    [self.backgroundImageView addSubview:self.questionNameLabel];
    
    [self _setupQuestionnarieBubbleConstraints];
}

- (void)updateQuestionnarieMargin:(UIEdgeInsets)margin
{
    if (_margin.top == margin.top && _margin.bottom == margin.bottom && _margin.left == margin.left && _margin.right == margin.right) {
        return;
    }
    _margin = margin;
    
    [self removeConstraints:self.marginConstraints];
    [self _setupQuestionnarieBubbleMarginConstraints];
}

@end
