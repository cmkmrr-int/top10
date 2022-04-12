import * as React from 'react';

const Business = ({item}) =>  {
	return (
		<div className='business'>
			Business Name {item.name}
		</div>
	);
}

class TopSearch extends React.Component {
	constructor(props) {
		super(props);
		this.state = {
			value: '',
			searchResults: null,
			isLoaded: false,
			error: null
		}

		this.handleChange = this.handleChange.bind(this);
		this.handleSubmit = this.handleSubmit.bind(this);
	}

	handleChange(event) {
		this.setState({value: event.target.value});
	}

	handleSubmit(event) {
		console.log("Looking in city " + this.state.value);

		const reqOpts = {
			method: 'POST',
			headers: { 'Content-Type': 'application/json' },
			body: JSON.stringify({ searchCity: this.state.value })
		}

		fetch('/api/getTop10ByCity', reqOpts)
		  .then(result => result.json())
		  .then(
			  (result) => {
			     this.setState({
				     searchResults: result.items,
				     isLoaded: true,
				     error: null
				  })
			  },
			  (error) => {
				  this.setState({
					  error,
					  isLoaded: true,
					  searchResults: null
				  })
			  }
		  );
	}

	render() {
		return (
			<div className='top-search'>
				<input
				  name="city"
				  type="text"
				  placeholder="City..."
				  onChange={this.handleChange}
				  value={this.state.value} />
				<button onClick={this.handleSubmit}>Find Top 10</button>

				{this.state.error ? (
					<div className='search-error'>Error while searching: {this.state.error.message}</div>
				) : (
					<div>
					{!this.state.isLoaded ? (
						<div>Please search a city above</div>
					) : (
						<div>
						{this.state.searchResults && this.state.searchResults.length > 0 ? (
							<div className='search-results'>
								{this.state.searchResults.map((item, idx) => (
        	                                                        <Business key={idx} item={item} />
                	                                        ))}
							</div>
						) : (
							<div className='no-results'>No results found for {this.state.value}, please try a different search</div>
						)}
						</div>
						

					)}
					</div>

				)}

			</div>
		);
	}
}

export default TopSearch

