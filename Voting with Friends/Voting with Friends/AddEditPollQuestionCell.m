//
//  AddEditPollQuestionCell.m
//  Voting with Friends
//
//  Created by Ryan Wahle on 3/24/15.
//  Copyright (c) 2015 Ryan Wahle. All rights reserved.
//

#import "AddEditPollQuestionCell.h"

@interface AddEditPollQuestionCell ()

@property NSString *placeholderString;

@end


@implementation AddEditPollQuestionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _placeholderString = @"Type your question for this poll here.";
    
    [self textViewDidEndEditing:_questionUITextView];
}

- (void)textViewDidChange:(UITextView *)textView {
    [UIView setAnimationsEnabled:NO];
    
    [[self parentTableView] beginUpdates];
    [[self parentTableView] endUpdates];
    
    [UIView setAnimationsEnabled:YES];
    
    [[self parentTableView] scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}



- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:_placeholderString]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:@""]) {
        textView.text = _placeholderString;
        textView.textColor = [UIColor lightGrayColor];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"addEditPoll_saveQuestionForPoll" object:textView];
}

-(UITableView *) parentTableView {
    // iterate up the view hierarchy to find the table containing this cell/view
    UIView *aView = self.superview;
    while(aView != nil) {
        if([aView isKindOfClass:[UITableView class]]) {
            return (UITableView *)aView;
        }
        aView = aView.superview;
    }
    return nil; // this view is not within a tableView
}


@end
