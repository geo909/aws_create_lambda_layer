code_folder = app
function = everypay-type2-notifier
zip_file = $(function).zip
s3_bucket = george-home
s3_bucket-fh = tzanakis
s3_key = Lambda/Code/$(zip_file)

zip:
	[ ! -e $(zip_file) ] || sudo rm $(zip_file)
	7z a -x'!_trash' -x'!__pycache__' -x'!data.json' $(zip_file) ./$(code_folder)/*

s3:
	aws s3 cp $(zip_file) s3://$(s3_bucket)/$(s3_key)

update:
	make zip
	make s3
	aws lambda update-function-code --function-name $(function) --s3-bucket $(s3_bucket) --s3-key $(s3_key)
	# You can add the --publish flag as well in the above line

s3-fh:
	aws --profile ferryhopper s3 cp $(zip_file) s3://$(s3_bucket-fh)/$(s3_key)

update-fh:
	make zip
	make s3-fh
	aws --profile ferryhopper lambda update-function-code --function-name $(function) --s3-bucket $(s3_bucket-fh) --s3-key $(s3_key)

