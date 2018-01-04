

# 生成api对象

main.go
```go
	apiv := api.New(
		alerts,
		silences,
		func(matchers []*labels.Matcher) dispatch.AlertOverview {
			return disp.Groups(matchers)
		},
		marker.Status,
		mrouter,
	)
```

## getAlertStatus

```go
		func(matchers []*labels.Matcher) dispatch.AlertOverview {
			return disp.Groups(matchers)
		}
```

dispatch.go Groups
```go
				status := d.marker.Status(a.Fingerprint())
				aa := &APIAlert{
					Alert:       a,
					Status:      status,
					Fingerprint: a.Fingerprint().String(),
				}
```