import { useRef, useState } from "react";


function NewObituary({toggleFunc}) {
  
  const nameInputRef = useRef(null);
  const imageInputRef = useRef(null)

  const birthInputRef = useRef(null); 
  const deathInputRef = useRef(null);

  const [obituary, setObituary] = useState("");

  const [name, setName] = useState("")



  function handleWriteObituary() {

    // const lambdaUrl = 'https://ssktty0sdj.execute-api.ca-central-1.amazonaws.com/url/the-last-show'
    const lambdaUrl = 'https://ssktty0sdj.execute-api.ca-central-1.amazonaws.com/final-project/the-last-show'

    // https://ssktty0sdj.execute-api.ca-central-1.amazonaws.com/final-project
    // const lambdaUrl = "https://gxeuwncossi426x5df3fxe7rau0mskds.lambda-url.ca-central-1.on.aws/"


    const name = nameInputRef.current.value;
    if (!name) {
      alert("Please enter the name of the deceased.");
      return;
    }

    const image = imageInputRef.current.value;
    const birth = birthInputRef.current.value;
    const death = deathInputRef.current.value; 
    const imgtype = image.split('.').pop();

    // const birth = birthInputRef.current.value; 
    // const death = deathInputRef.current.value;

    const requestOptions = {
      method: 'POST',
      mode: 'no-cors',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({name: name, birth: birth, death: death, image: image, imgtype: imgtype}) 
    };

    fetch(lambdaUrl, requestOptions)
      .then(response => response.json())
      .then(data => {
        console.log(data);
        setObituary(data.obituary); // set the obituary in state
       
    })

      .catch(error => console.log(error));
      toggleFunc()
  }

  // to prevent scrolling when new NewObituary entry is clicked
  // if(modal) {
  //   document.body.classList.add('active-modal')
  // } else {
  //   document.body.classList.remove('active-modal')
  // }

    return (
      <>

        <div className="modal">
          <div onClick={toggleFunc} className="overlay"></div>
          <div className="modal-content">
            <h2 className='new-obituary-title'>Create a New Obituary</h2>
            <div className="new-obituary-floral">
              <img src="floral.png" alt=""></img>
            </div>

            &nbsp;

            
              <p className="new-obituary-title">
                Select an image for the deceased
              </p>
              <div className="button"><input type="file"></input></div>

            &nbsp;

            <div className="name-input-field">
              <input
              value={name}
              onChange={(e) => setName(e.target.value)}
              ref={nameInputRef} style={{color:"grey"}}
              type="text"
              defaultValue={"Name of the deceased"}/>
            </div>

            &nbsp;

            <div className="born-died-beside">
              <div>
                <p className="born-died">Born: </p>
                <input ref={birthInputRef} type="datetime-local" />
              </div>
              &nbsp;&nbsp;&nbsp;&nbsp;
              <div>
                <p className="born-died">Died: </p>
                <input ref={deathInputRef} type="datetime-local" />
              </div>
            </div>

            <div className="button">
              <button onClick={handleWriteObituary} className="write-obituary-button">Write Obituary</button>
            </div>

            <button className="close-modal" onClick={toggleFunc}>
              X
            </button>
          </div>
        </div>
    </>
    )
  }
  
export default NewObituary;