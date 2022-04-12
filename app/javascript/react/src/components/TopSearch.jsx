import * as React from 'react';

const Business = ({item}) =>  {
	return (
		<div className='business' style={{clear: 'both'}}>
			<div className='image' style={{float: 'left', marginTop: '5px'}}>
				<img src={item.image} style={{maxHeight: '200px', maxWidth: '200px'}}/>
			</div>
			<div className='info'>
			<a href={item.url}>{item.name}</a> Price: {item.price}<br/>
			{item.categories.join(', ')} 
			</div>
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
		  <div>
			<div className='top-search'>
				<input
				  name="city"
				  type="text"
				  placeholder="City..."
				  onChange={this.handleChange}
				  onKeyPress={event => event.key === 'Enter' && this.handleSubmit(event)}
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
			<div style={{clear: 'both', marginTop: '15px'}}>
				Powered by <a href="https://yelp.com">Yelp</a>
			</div>
		  </div>
		);
	}
}

export default TopSearch

