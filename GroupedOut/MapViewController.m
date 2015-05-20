//
//  MapViewController.m
//  GroupedOut
//
//  Created by Charley Luckhardt on 3/30/15.
//  Copyright (c) 2015 Charley Luckhardt. All rights reserved.
//

#import "MapViewController.h"
#import "PlaceAnnotation.h"
#import "GOLocationManager.h"

@interface MapViewController () <GOLocationManagerDelegate>

@property (nonatomic, strong) NSArray *mapItemList;
@property (nonatomic, assign) MKCoordinateRegion userLocationRegion;
@property (nonatomic, assign) MKCoordinateRegion searchBoundingRegion;
@property (nonatomic, strong) NSArray *places;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) PlaceAnnotation *annotation;
@property (nonatomic, strong) CLGeocoder *geocoder;

@property (nonatomic, strong) MKLocalSearch *localSearch;
@property (nonatomic, strong) GOLocationManager *locationManager;
//@property (nonatomic, strong) CLLocation *userLocation;
//@property (nonatomic) CLLocationCoordinate2D userLocation;

- (IBAction)handleDropPin:(id)sender;
- (void)setBoundingRegionForUserLocation;

@end


@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mapView.showsUserLocation = YES;
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 0.75; //user needs to press for 1.5 seconds
    [self.mapView addGestureRecognizer:lpgr];
    
    //UITableViewCell *mapSearchCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MapSearchCell"];
    
    // start by locating user's current position
    self.locationManager = [GOLocationManager instance];
    self.locationManager.delegate = self;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.locationManager startUpdatingUserLocation];
    [self setBoundingRegionForUserLocation];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // adjust the map to zoom/center to the annotations we want to show
    [self.mapView setRegion:self.userLocationRegion];
    
    /*
    if (self.mapItemList.count == 1)
    {
        MKMapItem *mapItem = [self.mapItemList objectAtIndex:0];
        
        self.title = mapItem.name;
        
        // add the single annotation to our map
        PlaceAnnotation *annotation = [[PlaceAnnotation alloc] init];
        annotation.coordinate = mapItem.placemark.location.coordinate;
        annotation.title = mapItem.name;
        annotation.url = mapItem.url;
        [self.mapView addAnnotation:annotation];
        
        // we have only one annotation, select it's callout
        [self.mapView selectAnnotation:[self.mapView.annotations objectAtIndex:0] animated:YES];
        
        // center the region around this map item's coordinate
        self.mapView.centerCoordinate = mapItem.placemark.coordinate;
    }
    else
    {
        self.title = @"All Places";
        
        // add all the found annotations to the map
        for (MKMapItem *item in self.mapItemList)
        {
            PlaceAnnotation *annotation = [[PlaceAnnotation alloc] init];
            annotation.coordinate = item.placemark.location.coordinate;
            annotation.title = item.name;
            annotation.url = item.url;
            [self.mapView addAnnotation:annotation];
        }
    }
     */
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.locationManager stopUpdatingUserLocation];
    [self.mapView removeAnnotations:self.mapView.annotations];
}

- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
        return;
    
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
    CLLocationCoordinate2D touchMapCoordinate = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    
    if (self.annotation) {
        [self.mapView removeAnnotation:self.annotation];
    }
    self.annotation = [[PlaceAnnotation alloc] init];
    self.annotation.coordinate = touchMapCoordinate;
    [self.mapView addAnnotation:self.annotation];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:self.annotation.coordinate.latitude longitude:self.annotation.coordinate.longitude];
    [self reverseGeocodeLocation:location];
}

- (void)reverseGeocodeLocation:(CLLocation *)location {
    
    [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemark, NSError *error) {
        
        //initialize the title to "unknown" in case geocode has failed...
        self.annotation.title = @"Address unknown";
        
        //set the title if we got any placemarks...
        if (placemark.count > 0)
        {
            CLPlacemark *topResult = [placemark objectAtIndex:0];
            self.annotation.title = [NSString stringWithFormat:@"%@ %@ %@ %@", topResult.country, topResult.locality, topResult.subLocality, topResult.thoroughfare];
        }
    }];
}

- (void)setBoundingRegionForUserLocation {
    
    MKCoordinateRegion newRegion;
    newRegion.center.latitude = self.locationManager.userLocation.coordinate.latitude;
    newRegion.center.longitude = self.locationManager.userLocation.coordinate.longitude;
    newRegion.span.latitudeDelta = 0.112872;
    newRegion.span.longitudeDelta = 0.109863;
    
    self.userLocationRegion = newRegion;
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    MKPinAnnotationView *annotationView = nil;
    if ([annotation isKindOfClass:[PlaceAnnotation class]])
    {
        annotationView = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:@"Pin"];
        if (annotationView == nil)
        {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Pin"];
            annotationView.canShowCallout = YES;
            annotationView.animatesDrop = YES;
            [annotationView setDraggable:YES];
        }
    }
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView
 annotationView:(MKAnnotationView *)annotationView
didChangeDragState:(MKAnnotationViewDragState)newState
   fromOldState:(MKAnnotationViewDragState)oldState
{
    if (newState == MKAnnotationViewDragStateEnding)
    {
        [self.annotation setCoordinate:annotationView.annotation.coordinate];
        CLLocation *location = [[CLLocation alloc] initWithLatitude:self.annotation.coordinate.latitude longitude:self.annotation.coordinate.longitude];
        [self reverseGeocodeLocation:location];
        
    }
}

#pragma mark - UITableView delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.places count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MapSearchCell" forIndexPath:indexPath];
    
    MKMapItem *mapItem = [self.places objectAtIndex:indexPath.row];
    cell.textLabel.text = mapItem.name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // pass the new bounding region to the map destination view controller
    //self.mapViewController.boundingRegion = self.boundingRegion;
    
    // pass the individual place to our map destination view controller
    //NSIndexPath *selectedItem = [self.tableView indexPathForSelectedRow];
    //self.mapViewController.mapItemList = [NSArray arrayWithObject:[self.places objectAtIndex:selectedItem.row]];
    
    //[self.detailSegue perform];
}


#pragma mark - UISearchBarDelegate

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    [searchBar resignFirstResponder];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
}

- (void)startSearch:(NSString *)searchString
{
    if (self.localSearch.searching)
    {
        [self.localSearch cancel];
    }
    
    // confine the map search area to the user's current location
    MKCoordinateRegion newRegion;
    newRegion.center.latitude = self.locationManager.userLocation.coordinate.latitude;
    newRegion.center.longitude = self.locationManager.userLocation.coordinate.longitude;
    
    // setup the area spanned by the map region:
    // we use the delta values to indicate the desired zoom level of the map,
    //      (smaller delta values corresponding to a higher zoom level)
    //
    newRegion.span.latitudeDelta = 0.112872;
    newRegion.span.longitudeDelta = 0.109863;
    
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    
    request.naturalLanguageQuery = searchString;
    request.region = newRegion;
    
    MKLocalSearchCompletionHandler completionHandler = ^(MKLocalSearchResponse *response, NSError *error)
    {
        if (error != nil)
        {
            NSString *errorStr = [[error userInfo] valueForKey:NSLocalizedDescriptionKey];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could not find places"
                                                            message:errorStr
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        else
        {
            self.places = [response mapItems];
            
            // used for later when setting the map's region in "prepareForSegue"
            self.searchBoundingRegion = response.boundingRegion;
            
            //self.dropPinButton.enabled = self.places != nil ? YES : NO;
            
            [self.searchDisplayController.searchResultsTableView reloadData];
        }
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    };
    
    if (self.localSearch != nil)
    {
        self.localSearch = nil;
    }
    self.localSearch = [[MKLocalSearch alloc] initWithRequest:request];
    
    [self.localSearch startWithCompletionHandler:completionHandler];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    
    // check to see if Location Services is enabled, there are two state possibilities:
    // 1) disabled for entire device, 2) disabled just for this app
    //
    NSString *causeStr = nil;
    
    // check whether location services are enabled on the device
    if ([CLLocationManager locationServicesEnabled] == NO)
    {
        causeStr = @"device";
    }
    // check the application’s explicit authorization status:
    else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
    {
        causeStr = @"app";
    }
    else
    {
        // we are good to go, start the search
        [self startSearch:searchBar.text];
    }
    
    if (causeStr != nil)
    {
        NSString *alertMessage = [NSString stringWithFormat:@"You currently have location services disabled for this %@. Please refer to \"Settings\" app to turn on Location Services.", causeStr];
        
        UIAlertView *servicesDisabledAlert = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled"
                                                                        message:alertMessage
                                                                       delegate:nil
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil];
        [servicesDisabledAlert show];
    }
}

#pragma mark - GOLocationManagerDelegate methods

- (void)goLocationManagerDidUpdateLocation:(BOOL)success {
    
    [self setBoundingRegionForUserLocation];
    [self.mapView setRegion:self.userLocationRegion];
}

/*
#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    // remember for later the user's current location
    self.userLocation = newLocation.coordinate;
    self.boundingRegion.center = self.locationManager.userLocation.coordinate;
    
    [manager stopUpdatingLocation]; // we only want one update
    
    //manager.delegate = nil;         // we might be called again here, even though we
    // called "stopUpdatingLocation", remove us as the delegate to be sure
    
    self.dropPinButton.enabled = YES;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    // report any errors returned back from Location Services
}
*/
@end

