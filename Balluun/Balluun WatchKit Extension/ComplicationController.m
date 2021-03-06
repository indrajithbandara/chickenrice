//
//  ComplicationController.m
//  Balluun
//
//  Created by Jeremy Foo on 12/7/15.
//  Copyright © 2015 Ottoman. All rights reserved.
//

#import <WatchKit/WatchKit.h>

#import "ComplicationController.h"
#import "BLNDirectReport.h"

@implementation ComplicationController

#pragma mark - Timeline Configuration

- (void)getSupportedTimeTravelDirectionsForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationTimeTravelDirections directions))handler
{
    handler(CLKComplicationTimeTravelDirectionBackward);
}

- (void)getTimelineStartDateForComplication:(CLKComplication *)complication withHandler:(void(^)(__nullable NSDate *date))handler
{
    handler([[[BLNDirectReport sharedInstance].sortedIndexItems firstObject] timestamp]);
}

- (void)getTimelineEndDateForComplication:(CLKComplication *)complication withHandler:(void(^)(__nullable NSDate *date))handler
{
    handler([[[BLNDirectReport sharedInstance].sortedIndexItems lastObject] timestamp]);
}

- (void)getPrivacyBehaviorForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationPrivacyBehavior privacyBehavior))handler
{
    handler(CLKComplicationPrivacyBehaviorShowOnLockScreen);
}

#pragma mark - Timeline Population

- (void)getCurrentTimelineEntryForComplication:(CLKComplication *)complication withHandler:(void(^)(__nullable CLKComplicationTimelineEntry *))handler
{
    // Call the handler with the current timeline entry
    _BLNBallonIndexItem *currentIndexItem = [[BLNDirectReport sharedInstance].sortedIndexItems lastObject];
    if (!currentIndexItem)
    {
        handler(nil);
        return;
    }
    handler(TimeLineEntry(complication, currentIndexItem));
}

- (void)getTimelineEntriesForComplication:(CLKComplication *)complication beforeDate:(NSDate *)date limit:(NSUInteger)limit withHandler:(void(^)(__nullable NSArray<CLKComplicationTimelineEntry *> *entries))handler
{
    _BLNBallonIndexItem *currentIndexItem = [[BLNDirectReport sharedInstance].sortedIndexItems lastObject];
    NSArray *indexItems = [[BLNDirectReport sharedInstance].sortedIndexItems filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"timestamp < %@ AND SELF != %@", date, currentIndexItem]];
    NSArray *prunedItems = [indexItems subarrayWithRange:NSMakeRange(0, MIN(limit, [indexItems count]))];
    
    NSMutableArray *finalEntries = [NSMutableArray arrayWithCapacity:[prunedItems count]];
    for (_BLNBallonIndexItem *item in prunedItems)
    {
        CLKComplicationTimelineEntry *entry = TimeLineEntry(complication, item);
        [finalEntries addObject:entry];
    }
    
    handler(finalEntries);
}

- (void)getTimelineEntriesForComplication:(CLKComplication *)complication afterDate:(NSDate *)date limit:(NSUInteger)limit withHandler:(void(^)(__nullable NSArray<CLKComplicationTimelineEntry *> *entries))handler
{
    _BLNBallonIndexItem *currentIndexItem = [[BLNDirectReport sharedInstance].sortedIndexItems lastObject];
    NSArray *indexItems = [[BLNDirectReport sharedInstance].sortedIndexItems filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"timestamp > %@ AND SELF != %@", date, currentIndexItem]];
    if ([indexItems count] == 0)
    {
        handler(nil);
        return;
    }
    NSUInteger length = MIN(limit, [indexItems count]);
    NSArray *prunedItems = [indexItems subarrayWithRange:NSMakeRange([indexItems count] - length, length)];
    
    NSMutableArray *finalEntries = [NSMutableArray arrayWithCapacity:[prunedItems count]];
    for (_BLNBallonIndexItem *item in prunedItems)
    {
        CLKComplicationTimelineEntry *entry = TimeLineEntry(complication, item);
        [finalEntries addObject:entry];
    }
    
    handler(finalEntries);
}

#pragma mark Update Scheduling

- (void)getNextRequestedUpdateDateWithHandler:(void(^)(__nullable NSDate *updateDate))handler
{
    // Call the handler with the date when you would next like to be given the opportunity to update your complication content
    handler([[NSDate date] dateByAddingTimeInterval:1]);
}

#pragma mark - Placeholder Templates

- (void)getPlaceholderTemplateForComplication:(CLKComplication *)complication withHandler:(void(^)(__nullable CLKComplicationTemplate *complicationTemplate))handler
{
    handler(ComplicationTemplate(complication, nil));
}

static CLKComplicationTimelineEntry* TimeLineEntry(CLKComplication *complication, _BLNBallonIndexItem *indexItem)
{
    CLKComplicationTemplate *template = ComplicationTemplate(complication, indexItem);
    return [CLKComplicationTimelineEntry entryWithDate:indexItem.timestamp complicationTemplate:template];
}

static CLKComplicationTemplate* ComplicationTemplate(CLKComplication *complication, _BLNBallonIndexItem *indexItem)
{
    NSString *text = @":(";
    float fillFraction = 0.0;
    if (indexItem)
    {
        text = [NSString stringWithFormat:@"%i", indexItem.alertState];
        fillFraction = (float)indexItem.alertState / (float)BLNAlertStateDEFCON;
    }
    
    CLKComplicationTemplate *template = nil;
    
    // This method will be called once per supported complication, and the results will be cached
    switch (complication.family) {
        case CLKComplicationFamilyModularSmall:
            template = [CLKComplicationTemplateModularSmallRingText new];
            [(CLKComplicationTemplateModularSmallRingText *)template setRingStyle:CLKComplicationRingStyleClosed];
            [(CLKComplicationTemplateModularSmallRingText *)template setFillFraction:fillFraction];
            [(CLKComplicationTemplateModularSmallRingText *)template setTextProvider:[CLKSimpleTextProvider textProviderWithText:text]];
            break;
        case CLKComplicationFamilyCircularSmall:
            template = [CLKComplicationTemplateCircularSmallRingText new];
            [(CLKComplicationTemplateCircularSmallRingText *)template setRingStyle:CLKComplicationRingStyleClosed];
            [(CLKComplicationTemplateCircularSmallRingText *)template setFillFraction:fillFraction];
            [(CLKComplicationTemplateCircularSmallRingText *)template setTextProvider:[CLKSimpleTextProvider textProviderWithText:text]];
            break;
        case CLKComplicationFamilyUtilitarianSmall:
            template = [CLKComplicationTemplateUtilitarianSmallRingText new];
            [(CLKComplicationTemplateUtilitarianSmallRingText *)template setRingStyle:CLKComplicationRingStyleClosed];
            [(CLKComplicationTemplateUtilitarianSmallRingText *)template setFillFraction:fillFraction];
            [(CLKComplicationTemplateUtilitarianSmallRingText *)template setTextProvider:[CLKSimpleTextProvider textProviderWithText:text]];
            break;
        default:
            break;
    }
    
    return template;
}

@end
