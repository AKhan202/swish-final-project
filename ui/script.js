function submitForm() {
    var baseImage = document.getElementById('baseImage').value;
    var packages = document.getElementById('packages').value;
    var cpu = document.getElementById('cpu').value;
    var memory = document.getElementById('memory').value;

    // Construct payload to send to Jenkins
    var formData = new FormData();
    formData.append('BASE_IMAGE', baseImage);
    formData.append('PACKAGES', packages);
    formData.append('CPU', cpu);
    formData.append('MEMORY', memory);

    // Jenkins job URL (replace with your actual Jenkins job URL)
    var jenkinsJobUrl = 'https://your-jenkins-server/job/your-job-name/build';

    // POST request to trigger Jenkins job
    fetch(jenkinsJobUrl, {
        method: 'POST',
        body: formData
    })
    .then(response => {
        if (!response.ok) {
            throw new Error('Network response was not ok');
        }
        return response.json();
    })
    .then(data => {
        console.log('Build started:', data);
        alert('Build started. Check Jenkins for progress.');
    })
    .catch(error => {
        console.error('Error:', error);
        alert('Error starting build. Please try again.');
    });
}
