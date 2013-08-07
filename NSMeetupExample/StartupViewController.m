//
//  StartupViewController.m
//  NSMeetupExample
//
//  Created by sjg@mousebirdconsulting.com on 8/6/13.
//

#import "StartupViewController.h"
#import "ViewController.h"

@implementation StartupViewController
{
    NSArray *codeSnippets;
}

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
    
    // The code snippets we know about
    codeSnippets = @[@{@"name": @"View Controller - Single Cube",
                       @"url": @"https://gist.github.com/mousebird/6170096.js"},
                     @{@"name": @"SimpleGLObject - Header",
                       @"url": @"https://gist.github.com/mousebird/6170256.js"},
                     @{@"name": @"SimpleGLObject - Body",
                       @"url": @"https://gist.github.com/mousebird/6170264.js"},
                     @{@"name": @"FlexiVertexBuffer - Header",
                       @"url": @"https://gist.github.com/mousebird/6170268.js"},
                     @{@"name": @"FlexiVertexBuffer - Body",
                       @"url": @"https://gist.github.com/mousebird/6170271.js"},
                     @{@"name": @"ViewController - Full",
                       @"url": @"https://gist.github.com/mousebird/6170317.js"}
                     ];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int numRow = 0;
    switch (section)
    {
        case 0:
            numRow = MaxTestModes;
            break;
        case 1:
            numRow = [codeSnippets count];
            break;
    }
    return numRow;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *name = nil;
    
    switch (section)
    {
        case 0:
            name = @"Examples";
            break;
        case 1:
            name = @"Code Snippets";
            break;
    }
    
    return name;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];;

    switch (indexPath.section)
    {
        case 0:
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
                cell.textLabel.text = @"Lots of cubes (30,000), few buffers";
                break;
            case MeteredCubes:
                cell.textLabel.text = @"Add cubes during rendering - on main thread";
                break;
            case MeteredCubesMultiThread:
                cell.textLabel.text = @"Add cubes during rendering - on another thread";
                break;
            default:
                break;
        }
            break;
        case 1:
            cell.textLabel.text = ((NSDictionary *)codeSnippets[indexPath.row])[@"name"];
            break;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];

    if (indexPath.section == 0)
    {
        ViewController *viewC = nil;
        // Override point for customization after application launch.
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            viewC = [[ViewController alloc] initWithNibName:@"ViewController_iPhone" bundle:nil];
        } else {
            viewC = [[ViewController alloc] initWithNibName:@"ViewController_iPad" bundle:nil];
        }
        viewC.testMode = indexPath.row;
        viewC.title = cell.textLabel.text;
        
        [self.navigationController pushViewController:viewC animated:YES];
    } else {
        UIWebView *webView = [[UIWebView alloc] init];
        NSString *codeURL = ((NSDictionary *)codeSnippets[indexPath.row])[@"url"];
        [webView loadHTMLString:[NSString stringWithFormat:@"<script src=\"%@\"></script>\"",codeURL] baseURL:nil];
        UIViewController *webViewC = [[UIViewController alloc] init];
        webView.scalesPageToFit = YES;
        [webViewC.view addSubview:webView];
        webViewC.title = cell.textLabel.text;
        webView.frame = self.view.frame;
        [self.navigationController pushViewController:webViewC animated:YES];
    }
}

@end
