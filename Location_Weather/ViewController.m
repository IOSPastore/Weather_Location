//
//  ViewController.m
//  Location_Weather
//
//  Created by Zlatan Pastore on 16/10/7.
//  Copyright © 2016年 温子萱. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>

@interface ViewController ()<CLLocationManagerDelegate>
@property (nonatomic, strong) MKMapView * mapView;
@property (nonatomic, strong) CLLocationManager * locationManager;
@property (nonatomic, strong) UITextField * textField;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //创建视图
    _mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    [_mapView setDelegate:self];
    //    [_mapView setShowsUserLocation:YES];
    [_mapView setMapType:MKMapTypeStandard];
    [self.view addSubview:_mapView];
    
    _textField = [[UITextField alloc] init];
    [_textField setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_textField setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:_textField];
    
    
    
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setBackgroundColor:[UIColor orangeColor]];
    [btn setTitle:@"查找" forState:UIControlStateNormal];
    [btn setTranslatesAutoresizingMaskIntoConstraints:NO];
    [btn addTarget:self action:@selector(theBntPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_textField][btn(100)]-20-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_textField,btn)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[_textField(30)]-(-30)-[btn(30)]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_textField,btn)]];
    
    //检测定位服务是否开启
    if ([CLLocationManager locationServicesEnabled]) {
        _locationManager = [[CLLocationManager alloc] init];
        if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [_locationManager requestWhenInUseAuthorization];
        }
        //设置代理
        [_locationManager setDelegate:self];
        //设置精度
        [_locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        //设置距离筛选
        [_locationManager setDistanceFilter:10];
        //开始定位
        [_locationManager startUpdatingLocation];
        
        
        
    }else{
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:nil
                                                             message:@"定位没有开启"
                                                            delegate:nil
                                                   cancelButtonTitle:@"确定"
                                                   otherButtonTitles:nil, nil];
        [alertView show];
    }
    
    
}

//点击按钮后执行

- (void)theBntPressed:(id)sender {
    [_textField resignFirstResponder];
    if ([_textField.text length] == 0) {
        return;
    }
    [self geocoder:_textField.text];
    
    
}
//授权状态发生改变
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    switch (status) {
        case kCLAuthorizationStatusDenied:{
            UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:nil message:@"定位功能没有开启" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
            
        }
            break;
            
        default:
            break;
    }
}
// 测试经纬度： 112.529578,37.864093
//定位成功
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    CLLocation * location = locations.lastObject;
    [self reverseGeocoder:location];
        MKCoordinateRegion coordinateRegion = MKCoordinateRegionMake(CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude), MKCoordinateSpanMake(0.1, 0.1));
    
        [_mapView setRegion:[_mapView regionThatFits:coordinateRegion] animated:YES];
}
//定位失败
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    
}
//反地理编码
#pragma make Geocoder
- (void)reverseGeocoder:(CLLocation *)currentLocation {
    CLGeocoder * geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if(error || placemarks.count == 0){
            NSLog(@"error");
        }else{
            CLPlacemark * placemark = placemarks.firstObject;
            
            //
            MKCoordinateRegion coordinateRegion = MKCoordinateRegionMake(CLLocationCoordinate2DMake(placemark.location.coordinate.latitude, placemark.location.coordinate.longitude), MKCoordinateSpanMake(0.1, 0.1));
            
            [_mapView setRegion:[_mapView regionThatFits:coordinateRegion] animated:YES];
            
            MKPointAnnotation * pointAnnotation = [[MKPointAnnotation alloc] init];
            [pointAnnotation setTitle:placemark.name];
            [pointAnnotation setCoordinate:CLLocationCoordinate2DMake(placemark.location.coordinate.latitude, placemark.location.coordinate.longitude)];
            [_mapView addAnnotation:pointAnnotation];
            
            NSLog(@"placemark:%@",[[placemark addressDictionary] objectForKey:@"city"]);
        }
    }];
}
//地理编码
- (void)geocoder:(NSString *)str {
    CLGeocoder * geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:str completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (error || placemarks.count == 0) {
            NSLog(@"error");
        }else{
            CLPlacemark * placemark = placemarks.firstObject;
            
            MKCoordinateRegion coordinateRegion = MKCoordinateRegionMake(CLLocationCoordinate2DMake(placemark.location.coordinate.latitude, placemark.location.coordinate.longitude), MKCoordinateSpanMake(0.1, 0.1));
            
            [_mapView setRegion:[_mapView regionThatFits:coordinateRegion] animated:YES];
            
            MKPointAnnotation * pointAnnotation = [[MKPointAnnotation alloc] init];
            [pointAnnotation setTitle:placemark.name];
            [pointAnnotation setCoordinate:CLLocationCoordinate2DMake(placemark.location.coordinate.latitude, placemark.location.coordinate.longitude)];
            [_mapView addAnnotation:pointAnnotation];
            
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}
@end

