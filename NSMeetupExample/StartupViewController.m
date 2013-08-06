//
//  StartupViewController.m
//  NSMeetupExample
//
//  Created by Steve Gifford on 8/6/13.
//  Copyright (c) 2013 mousebird consulting. All rights reserved.
//

#import "StartupViewController.h"
#import "ViewController.h"

@interface StartupViewController ()

@end

@implementation StartupViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"NSMeetup OpenGL Test";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return MaxTestModes;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];;

    switch (indexPath.row)
    {
        case SingleCube:
            cell.textLabel.text = @"Single cube";
            break;
        case MoreCubes:
            cell.textLabel.text = @"More cubes: 200";
            break;
        case ManyCubesManyBuffers:
            cell.textLabel.text = @"Lots of cubes, lots of buffers (10,000)";
            break;
        case ManyCubesFewBuffers:
            cell.textLabel.text = @"Lots of cubes (10,000), few buffers";
            break;
        case WholeLottaCubes:
            cell.textLabel.text = @"Lots of cubes (50,000), few buffers";
            break;
        default:
            break;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ViewController *viewC = nil;
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        viewC = [[ViewController alloc] initWithNibName:@"ViewController_iPhone" bundle:nil];
    } else {
        viewC = [[ViewController alloc] initWithNibName:@"ViewController_iPad" bundle:nil];
    }
    viewC.testMode = indexPath.row;
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    viewC.title = cell.textLabel.text;
    
    [self.navigationController pushViewController:viewC animated:YES];
}

@end
