using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RotateSlowly : MonoBehaviour
{
    float rotateSpeed;

    Vector3 randomRotation;


    // Start is called before the first frame update
    void Start()
    {
        randomRotation = new Vector3(Random.Range(0f, 1f), Random.Range(0f, 1f), Random.Range(0f, 1f));

        rotateSpeed = Random.Range(2f, 15f);
    }

    // Update is called once per frame
    void Update()
    {
        transform.Rotate(randomRotation * Time.deltaTime * rotateSpeed);
    }
}
