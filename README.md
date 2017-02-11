# NoneReuseTableView
A tableView without reuse.
## How to use it?

```oc
NoneReuseTableView *tableView = [NoneReuseTableView new];
[self.view addSubview:tableView];
[tableView mas_makeConstraints:^(MASConstraintMaker *make) {
	make.edges.equalTo(tableView.superview);
}];
tableView.scrollView.showsVerticalScrollIndicator = NO;
tableView.scrollView.showsHorizontalScrollIndicator = NO;
tableView.backgroundColor = [UIColor whiteColor];

UIView *testView = [[UIView alloc] init];
[tableView addCellView:testView cellHeight:10];
```


