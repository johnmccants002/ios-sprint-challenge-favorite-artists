//
//  ArtistsTableViewController.m
//  FavoriteArtists
//
//  Created by John McCants on 2/18/21.
//

#import "ArtistsTableViewController.h"
#import "Artist.h"
#import "ArtistModelController.h"
#import "ArtistsDetailViewController.h"

@interface ArtistsTableViewController ()

@property (nonatomic) ArtistModelController *artistModelController;
@end

@implementation ArtistsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _artistModelController = [[ArtistModelController alloc] init];
    [_artistModelController loadFromPersistentStore];
 
   
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _artistModelController.artists.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"artist" forIndexPath:indexPath];
    cell.textLabel.text = [_artistModelController.artists objectAtIndex: indexPath.row].artistName;
    int yearFormedInt = [_artistModelController.artists objectAtIndex:indexPath.row].yearFormed;
    NSString *yearFormedString = [NSString stringWithFormat:@"%i", yearFormedInt];
    
    cell.detailTextLabel.text = yearFormedString;

    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"addArtist"]) {
        ArtistsDetailViewController *destinationVC = (ArtistsDetailViewController *)segue.destinationViewController;
        destinationVC.artistModelController = _artistModelController;
    } else if ([segue.identifier isEqualToString:@"artistDetail"])
    {
        ArtistsDetailViewController *destinationVC = (ArtistsDetailViewController *)segue.destinationViewController;
        
        destinationVC.artist = [_artistModelController.artists objectAtIndex:[self.tableView indexPathForSelectedRow].row];
        destinationVC.artistModelController = _artistModelController;
    }
}


@end
